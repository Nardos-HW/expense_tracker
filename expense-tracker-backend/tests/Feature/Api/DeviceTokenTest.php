<?php

namespace Tests\Feature\Api;

use App\Models\Expense;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeviceTokenTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_requires_device_name(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['device_name']);
    }

    public function test_invalid_device_name_returns_422(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'unsupported-device',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['device_name']);
    }

    public function test_vue_web_device_name_rejected_by_default_on_public_login(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'vue-web',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['device_name']);
    }

    public function test_one_token_per_device_name_after_repeated_logins(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'flutter-mobile',
        ])->assertStatus(200);

        $this->assertCount(1, $user->tokens()->where('name', 'flutter-mobile')->get());

        $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'flutter-mobile',
        ])->assertStatus(200);

        $this->assertCount(1, $user->tokens()->where('name', 'flutter-mobile')->get());
    }

    public function test_mobile_token_can_read_and_create_expenses_but_gets_403_on_delete(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        $loginResponse = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'flutter-mobile',
        ]);

        $loginResponse->assertStatus(200);
        $token = $loginResponse->json('token');

        $headers = ['Authorization' => "Bearer {$token}"];

        // Can read
        $this->getJson('/api/expenses', $headers)
            ->assertStatus(200);

        // Can create
        $createResponse = $this->postJson('/api/expenses', [
            'title' => 'Test Mobile Expense',
            'amount' => '15.00',
            'expense_date' => '2026-10-17',
            'category' => 'Food',
        ], $headers);

        $createResponse->assertStatus(201)
            ->assertJsonPath('source', 'flutter-mobile');

        $expenseId = $createResponse->json('id');

        // Cannot delete (403 with specific message)
        $deleteResponse = $this->deleteJson("/api/expenses/{$expenseId}", [], $headers);
        $deleteResponse->assertStatus(403)
            ->assertJson([
                'message' => 'This device is not allowed to perform this action.',
            ]);
    }

    public function test_mobile_token_cannot_access_tokens_api(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        $loginResponse = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'flutter-mobile',
        ]);

        $token = $loginResponse->json('token');
        $headers = ['Authorization' => "Bearer {$token}"];

        $this->getJson('/api/tokens', $headers)
            ->assertStatus(403)
            ->assertJson([
                'message' => 'This device is not allowed to perform this action.',
            ]);

        $this->deleteJson('/api/tokens/1', [], $headers)
            ->assertStatus(403)
            ->assertJson([
                'message' => 'This device is not allowed to perform this action.',
            ]);
    }

    public function test_user_cannot_revoke_another_users_token(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        $token1 = $user1->createToken('vue-web', ['*']);
        $token2 = $user2->createToken('flutter-mobile', ['expenses:read']);

        // User 1 tries to delete User 2's token
        $response = $this->withToken($token1->plainTextToken)
            ->deleteJson("/api/tokens/{$token2->accessToken->id}");

        $response->assertStatus(404);
        $this->assertDatabaseHas('personal_access_tokens', [
            'id' => $token2->accessToken->id,
        ]);
    }

    public function test_revoking_token_returns_401(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        $loginResponse = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
            'device_name' => 'flutter-mobile',
        ]);

        $token = $loginResponse->json('token');
        $headers = ['Authorization' => "Bearer {$token}"];

        // Revoke the token
        $user->tokens()->delete();
        \Illuminate\Support\Facades\Auth::forgetGuards();

        // 401 after revoking
        $this->getJson('/api/expenses', $headers)->assertStatus(401);
    }

    public function test_expense_source_is_recorded_for_mobile_and_web_session(): void
    {
        $user = User::factory()->create([
            'password' => 'password',
        ]);

        // Mobile token
        $token = $user->createToken('flutter-mobile', ['expenses:create'])->plainTextToken;
        $responseMobile = $this->withToken($token)->postJson('/api/expenses', [
            'title' => 'Mobile Expense',
            'amount' => '10.00',
            'expense_date' => '2026-10-17',
            'category' => 'Transport',
        ]);
        $responseMobile->assertStatus(201)
            ->assertJsonPath('source', 'flutter-mobile');

        // Web session (actingAs without token)
        $responseSession = $this->actingAs($user)->postJson('/expenses', [
            'title' => 'Web Expense',
            'amount' => '20.00',
            'expense_date' => '2026-10-17',
            'category' => 'Food',
        ]);
        $responseSession->assertStatus(201)
            ->assertJsonPath('source', 'vue-web');
    }
}

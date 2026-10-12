<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Expense;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create one specific test user so you can log in easily
        $user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => bcrypt('password'), // password is 'password'
        ]);

        // Generate 50 fake expenses and assign them to this specific user
        Expense::factory(50)->create([
            'user_id' => $user->id,
        ]);
    }
}
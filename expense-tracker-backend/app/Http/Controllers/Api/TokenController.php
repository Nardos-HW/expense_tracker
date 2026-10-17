<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

class TokenController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $currentToken = $request->user()->currentAccessToken();
        $currentId = ($currentToken instanceof PersonalAccessToken)
            ? $currentToken->id
            : null;

        $tokens = $request->user()->tokens()
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($token) use ($currentId) {
                return [
                    'id' => $token->id,
                    'name' => $token->name,
                    'last_used_at' => $token->last_used_at,
                    'created_at' => $token->created_at,
                    'is_current' => $token->id === $currentId,
                ];
            });

        return response()->json($tokens);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $token = $request->user()->tokens()->whereKey($id)->firstOrFail();
        $token->delete();

        return response()->json(['message' => 'Token revoked successfully']);
    }
}

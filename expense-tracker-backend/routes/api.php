<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TokenController;
use App\Http\Controllers\ExpenseController;

// Public Route: Mobile Login & Register
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected Mobile Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Token management (Remote Logout prep)
    Route::get('/tokens', [TokenController::class, 'index'])->middleware('abilities:tokens:manage');
    Route::delete('/tokens/{id}', [TokenController::class, 'destroy'])->whereNumber('id')->middleware('abilities:tokens:manage');
    
    // Expose the same exact JSON methods your Vue app uses with platform ability checks
    Route::get('/expenses', [ExpenseController::class, 'index'])->middleware('abilities:expenses:read');
    Route::post('/expenses', [ExpenseController::class, 'store'])->middleware('abilities:expenses:create');
    Route::put('/expenses/{expense}', [ExpenseController::class, 'update'])->middleware('abilities:expenses:update');
    Route::delete('/expenses/{expense}', [ExpenseController::class, 'destroy'])->middleware('abilities:expenses:delete');
});
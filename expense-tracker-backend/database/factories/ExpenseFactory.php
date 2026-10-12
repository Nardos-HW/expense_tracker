<?php

namespace Database\Factories;

use App\Models\Expense;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Expense>
 */
class ExpenseFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            // Creates a new user for the expense if one isn't explicitly provided
            'user_id' => User::factory(), 
            
            // Generates a random 3-word title (e.g., "Weekly grocery run")
            'title' => fake()->words(3, true), 
            
            // Generates a random amount between $5.00 and $500.00
            'amount' => fake()->randomFloat(2, 5, 500), 
            
            // Generates a random date from the past year
            'expense_date' => fake()->dateTimeBetween('-1 year', 'now')->format('Y-m-d'), 
            
            // Picks one of these common expense categories randomly
            'category' => fake()->randomElement(['Food', 'Transport', 'Utilities', 'Entertainment', 'Shopping', 'Health']),
        ];
    }
}
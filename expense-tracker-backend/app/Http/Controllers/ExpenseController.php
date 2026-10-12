<?php

namespace App\Http\Controllers;

use App\Models\Expense;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ExpenseController extends Controller
{
    public function index()
    {
        // Eager loading completely prevents the N+1 bug
        $expenses = Expense::with('user')
            ->where('user_id', Auth::id())
            ->orderBy('expense_date', 'desc')
            ->get();
        return response()->json($expenses);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'expense_date' => 'required|date',
            'category' => 'nullable|string'
        ]);

        // Cleanly creates the expense attached to the authenticated user
        $expense = Auth::user()->expenses()->create($validated);

        return response()->json($expense, 201);
    }

    public function update(Request $request, Expense $expense)
    {
        if ($expense->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'amount' => 'sometimes|required|numeric|min:0.01',
            'expense_date' => 'sometimes|required|date',
            'category' => 'nullable|string'
        ]);

        $expense->update($validated);

        return response()->json($expense);
    }

    public function destroy(Expense $expense)
    {
        if ($expense->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $expense->delete();

        return response()->json(['message' => 'Expense deleted successfully']);
    }
}
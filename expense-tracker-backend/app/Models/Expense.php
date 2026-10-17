<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Expense extends Model
{
    use HasFactory;

    // Add this line to allow form data to be saved to these columns
    protected $fillable = ['title', 'amount', 'expense_date', 'category', 'source'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
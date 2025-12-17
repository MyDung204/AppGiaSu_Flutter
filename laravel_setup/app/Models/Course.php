<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    use HasFactory;
    protected $fillable = ['tutor_id', 'title', 'description', 'price', 'max_students', 'start_date', 'schedule', 'status'];
    protected $casts = [
        'start_date' => 'date',
        'price' => 'decimal:2',
    ];

    public function tutor()
    {
        return $this->belongsTo(Tutor::class);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class TutorMaterial extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'tutor_id',
        'name',
        'file_path',
        'file_type',
        'file_size',
    ];

    public function tutor()
    {
        return $this->belongsTo(User::class, 'tutor_id');
    }
}

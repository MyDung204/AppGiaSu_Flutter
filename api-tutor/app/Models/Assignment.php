<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Assignment extends Model
{
    protected $fillable = [
        'course_id',
        'study_group_id',
        'student_id',
        'title',
        'description',
        'due_date',
        'attachment_url',
    ];

    public function submissions()
    {
        return $this->hasMany(AssignmentSubmission::class);
    }

    public function studyGroup()
    {
        return $this->belongsTo(StudyGroup::class);
    }
}

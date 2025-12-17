<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\StudyGroup;
use App\Models\Course;
use Illuminate\Http\Request;

class SharedLearningController extends Controller
{
    // Get all Study Groups (Học ghép)
    public function indexGroups()
    {
        return StudyGroup::with('creator')->where('status', '!=', 'closed')->latest()->get();
    }

    // Get all Courses (Lớp học)
    public function indexCourses()
    {
        return Course::with('tutor')->where('status', '!=', 'closed')->latest()->get();
    }

    // Create a Study Group
    public function storeGroup(Request $request)
    {
        $validated = $request->validate([
            'topic' => 'required|string',
            'subject' => 'required|string',
            'grade_level' => 'required|string',
            'max_members' => 'required|integer',
            'description' => 'required|string',
        ]);

        $group = StudyGroup::create([
            'creator_id' => $request->user()->id,
            ...$validated,
            'current_members' => 1,
            'status' => 'open'
        ]);

        return response()->json($group, 201);
    }
}

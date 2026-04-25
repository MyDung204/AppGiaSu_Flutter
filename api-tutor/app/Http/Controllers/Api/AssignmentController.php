<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

use Illuminate\Http\Request;

class AssignmentController extends Controller
{
    private function userCanManageCourse(Request $request, $courseId, $studentId = null): bool
    {
        $user = $request->user();
        if ($user->role === 'admin') {
            return true;
        }

        if ($courseId) {
            $course = \App\Models\Course::findOrFail($courseId);
            $tutor = \App\Models\Tutor::where('user_id', $user->id)->first();
            return $user->role === 'tutor' && $tutor && $course->tutor_id == $tutor->id;
        }

        if ($studentId) {
            // For 1-1, tutor must have a booking or connection?
            // Simple check: user is tutor
            return $user->role === 'tutor';
        }

        return false;
    }

    public function index(Request $request)
    {
        $user = $request->user();
        $query = \App\Models\Assignment::query();

        if ($user->role === 'tutor') {
            // Tutor view
            if ($request->has('course_id')) {
                $query->where('course_id', $request->course_id);
            }
            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }
            // If no filters, show all by tutor?
            // Assuming Assignment model has tutor_id if we want that, 
            // but currently it relies on course_id -> course -> tutor_id.
            // For 1-1, we might need tutor_id in assignments too.
            // Let's check if Assignment model has tutor_id.
        } else {
            // Student view
            $courseIds = \Illuminate\Support\Facades\DB::table('course_students')->where('user_id', $user->id)->pluck('course_id');
            $query->where(function($q) use ($user, $courseIds) {
                $q->where('student_id', $user->id)
                  ->orWhereIn('course_id', $courseIds);
            });
        }

        $assignments = $query->withCount('submissions')
            ->orderBy('created_at', 'desc')
            ->get();

        if ($user->role === 'student') {
            $assignments->each(function ($assignment) use ($user) {
                $submission = $assignment->submissions()->where('student_id', $user->id)->first();
                $assignment->is_submitted = $submission ? true : false;
                $assignment->my_submission = $submission;
            });
        }

        return response()->json($assignments);
    }

    public function store(Request $request)
    {
        $request->validate([
            'course_id' => 'nullable|exists:courses,id',
            'student_id' => 'nullable|exists:users,id',
            'title' => 'required|string',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'attachment_url' => 'nullable|string',
        ]);

        if (!$request->course_id && !$request->student_id) {
            return response()->json(['message' => 'Phải chọn lớp học hoặc học viên.'], 422);
        }

        if (!$this->userCanManageCourse($request, $request->course_id, $request->student_id)) {
            return response()->json(['message' => 'Bạn không có quyền giao bài tập này.'], 403);
        }

        $assignment = \App\Models\Assignment::create($request->all());

        return response()->json($assignment, 201);
    }

    public function update(Request $request, $id)
    {
        $assignment = \App\Models\Assignment::findOrFail($id);

        if (!$this->userCanManageCourse($request, $assignment->course_id)) {
            return response()->json(['message' => 'Bạn không có quyền sửa bài tập này.'], 403);
        }

        $validated = $request->validate([
            'title' => 'sometimes|required|string',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'attachment_url' => 'nullable|string',
        ]);

        $assignment->update($validated);

        return response()->json($assignment->fresh());
    }

    public function submit(Request $request, $id)
    {
        $request->validate([
            'content' => 'nullable|string',
            'file_url' => 'nullable|string',
        ]);

        if (!$request->input('content') && !$request->input('file_url')) {
            return response()->json(['message' => 'Nội dung hoặc file không được để trống'], 422);
        }

        $user = $request->user();
        
        $submission = \App\Models\AssignmentSubmission::updateOrCreate(
            ['assignment_id' => $id, 'student_id' => $user->id],
            [
                'content' => $request->input('content'),
                'file_url' => $request->input('file_url'),
                'submitted_at' => now(),
            ]
        );

        return response()->json($submission);
    }

    public function submissions($id)
    {
        // Tutor view: Get all submissions
        $submissions = \App\Models\AssignmentSubmission::where('assignment_id', $id)
            ->with('student:id,name,avatar_url')
            ->orderBy('submitted_at', 'desc')
            ->get();
            
        return response()->json($submissions);
    }

    public function destroy(Request $request, $id)
    {
        $assignment = \App\Models\Assignment::find($id);
        if (!$assignment) {
            return response()->json(['message' => 'Not found'], 404);
        }
        if (!$this->userCanManageCourse($request, $assignment->course_id)) {
            return response()->json(['message' => 'Bạn không có quyền xóa bài tập này.'], 403);
        }
        $assignment->delete();
        return response()->json(['message' => 'Deleted']);
    }
}

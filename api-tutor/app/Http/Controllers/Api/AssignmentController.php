<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

use Illuminate\Http\Request;

class AssignmentController extends Controller
{
    private function userCanManageCourse(Request $request, $courseId, $studentId = null, $studyGroupId = null): bool
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

        if ($studyGroupId) {
            $group = \App\Models\StudyGroup::findOrFail($studyGroupId);
            return $user->role === 'tutor' && $group->tutor_id == $user->id;
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
            if ($request->has('study_group_id')) {
                $query->where('study_group_id', $request->study_group_id);
            }
            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }
        } else {
            // Student view
            $courseIds = \Illuminate\Support\Facades\DB::table('course_students')->where('user_id', $user->id)->pluck('course_id');
            $groupIds = \Illuminate\Support\Facades\DB::table('study_group_members')->where('user_id', $user->id)->pluck('study_group_id');
            
            $query->where(function($q) use ($user, $courseIds, $groupIds) {
                $q->where('student_id', $user->id)
                  ->orWhereIn('course_id', $courseIds)
                  ->orWhereIn('study_group_id', $groupIds);
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
            'study_group_id' => 'nullable|exists:study_groups,id',
            'student_id' => 'nullable|exists:users,id',
            'title' => 'required|string',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'attachment_url' => 'nullable|string',
        ]);

        if (!$request->course_id && !$request->student_id && !$request->study_group_id) {
            return response()->json(['message' => 'Phải chọn lớp học hoặc học viên.'], 422);
        }

        if (!$this->userCanManageCourse($request, $request->course_id, $request->student_id, $request->study_group_id)) {
            return response()->json(['message' => 'Bạn không có quyền giao bài tập này.'], 403);
        }

        $assignment = \App\Models\Assignment::create($request->all());

        return response()->json($assignment, 201);
    }

    public function update(Request $request, $id)
    {
        $assignment = \App\Models\Assignment::findOrFail($id);

        if (!$this->userCanManageCourse($request, $assignment->course_id, $assignment->student_id, $assignment->study_group_id)) {
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

    public function grade(Request $request, $id)
    {
        $submission = \App\Models\AssignmentSubmission::findOrFail($id);
        $assignment = $submission->assignment;

        if (!$this->userCanManageCourse($request, $assignment->course_id, $assignment->student_id, $assignment->study_group_id)) {
            return response()->json(['message' => 'Bạn không có quyền chấm điểm bài nộp này.'], 403);
        }

        $request->validate([
            'grade' => 'required|numeric|min:0|max:100',
            'feedback' => 'nullable|string',
        ]);

        $submission->update([
            'grade' => $request->grade,
            'feedback' => $request->feedback,
        ]);

        return response()->json($submission->fresh());
    }

    public function destroy(Request $request, $id)
    {
        $assignment = \App\Models\Assignment::find($id);
        if (!$assignment) {
            return response()->json(['message' => 'Not found'], 404);
        }
        if (!$this->userCanManageCourse($request, $assignment->course_id, $assignment->student_id, $assignment->study_group_id)) {
            return response()->json(['message' => 'Bạn không có quyền xóa bài tập này.'], 403);
        }
        $assignment->delete();
        return response()->json(['message' => 'Deleted']);
    }
}

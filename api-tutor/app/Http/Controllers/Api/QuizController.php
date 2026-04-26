<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Models\QuizOption;
use App\Models\QuizQuestion;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class QuizController extends Controller
{
    private function validateQuizPayload(Request $request, bool $isUpdate = false)
    {
        $questionRule = $isUpdate ? 'sometimes|array|min:1' : 'required|array|min:1';

        return Validator::make($request->all(), [
            'title' => ($isUpdate ? 'sometimes|' : 'required|') . 'string|max:255',
            'course_id' => 'nullable|integer|exists:courses,id',
            'student_id' => 'nullable|integer|exists:users,id',
            'study_group_id' => 'nullable|integer|exists:study_groups,id',
            'description' => 'nullable|string',
            'time_limit_minutes' => 'nullable|integer',
            'time_limit' => 'nullable|integer',
            'is_published' => 'boolean',
            'questions' => $questionRule,
            'questions.*.content' => 'required_with:questions|string',
            'questions.*.points' => 'required_with:questions|integer|min:1',
            'questions.*.options' => 'required_with:questions|array|min:2',
            'questions.*.options.*.content' => 'required_with:questions|string',
            'questions.*.options.*.is_correct' => 'required_with:questions|boolean',
        ]);
    }

    private function assertTutorOwnsCourse(Request $request)
    {
        if (!$request->filled('course_id')) {
            return null;
        }

        $course = \App\Models\Course::findOrFail($request->course_id);
        $tutor = \App\Models\Tutor::where('user_id', $request->user()->id)->first();

        if (!$tutor || $course->tutor_id != $tutor->id) {
            return response()->json(['message' => 'Bạn không có quyền gắn bài kiểm tra vào lớp này.'], 403);
        }

        return null;
    }

    // List quizzes (Tutor sees their own, Student sees published ones)
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role === 'tutor') {
            // Tutor: list my quizzes
            $query = Quiz::where('tutor_id', $user->id)
                ->withCount('questions');

            if ($request->has('course_id')) $query->where('course_id', $request->course_id);
            if ($request->has('student_id')) $query->where('student_id', $request->student_id);
            if ($request->has('study_group_id')) $query->where('study_group_id', $request->study_group_id);

            $quizzes = $query->latest()->get();
        } else {
            // Student: list published quizzes
            $courseIds = DB::table('course_students')->where('user_id', $user->id)->pluck('course_id');
            $groupIds = DB::table('study_group_members')->where('user_id', $user->id)->pluck('study_group_id');
            
            $query = Quiz::where('is_published', true)
                ->where(function($q) use ($user, $courseIds, $groupIds) {
                    $q->where('student_id', $user->id)
                      ->orWhereIn('course_id', $courseIds)
                      ->orWhereIn('study_group_id', $groupIds);
                })
                ->with('tutor');

            if ($request->has('course_id')) $query->where('course_id', $request->course_id);
            if ($request->has('study_group_id')) $query->where('study_group_id', $request->study_group_id);

            $quizzes = $query->latest()->get();
        }

        return response()->json($quizzes);
    }

    // Get quiz details
    public function show($id, Request $request)
    {
        $user = $request->user();
        $quiz = Quiz::with(['tutor'])->withCount('questions')->findOrFail($id);

        if ($user->role === 'student' && !$quiz->is_published) {
            return response()->json(['message' => 'Quiz not found or not published'], 404);
        }

        // Load questions. For students, hide 'is_correct' in options.
        if ($user->role === 'tutor' && $quiz->tutor_id === $user->id) {
            $quiz->load(['questions.options']);
            $quiz->load(['attempts.user:id,name,email,avatar_url']);

            $completedUserIds = $quiz->attempts->pluck('user_id')->unique()->values();
            $eligibleStudents = collect();

            if ($quiz->course_id) {
                $eligibleStudents = DB::table('course_students')
                    ->join('users', 'course_students.user_id', '=', 'users.id')
                    ->where('course_students.course_id', $quiz->course_id)
                    ->where('course_students.status', 'approved')
                    ->select('users.id', 'users.name', 'users.email', 'users.avatar_url')
                    ->get();
            } elseif ($quiz->study_group_id) {
                $eligibleStudents = DB::table('study_group_members')
                    ->join('users', 'study_group_members.user_id', '=', 'users.id')
                    ->where('study_group_members.study_group_id', $quiz->study_group_id)
                    ->whereIn('study_group_members.status', ['approved', 'member'])
                    ->select('users.id', 'users.name', 'users.email', 'users.avatar_url')
                    ->get();
            } elseif ($quiz->student_id) {
                $eligibleStudents = DB::table('users')
                    ->where('id', $quiz->student_id)
                    ->select('id', 'name', 'email', 'avatar_url')
                    ->get();
            }

            $quiz->completed_students = $quiz->attempts
                ->sortByDesc('completed_at')
                ->unique('user_id')
                ->map(function ($attempt) {
                    return [
                        'id' => $attempt->user?->id,
                        'name' => $attempt->user?->name ?? 'Học viên',
                        'email' => $attempt->user?->email,
                        'avatar_url' => $attempt->user?->avatar_url,
                        'score' => $attempt->score,
                        'completed_at' => optional($attempt->completed_at)->toIso8601String(),
                    ];
                })
                ->values();

            $quiz->pending_students = $eligibleStudents
                ->whereNotIn('id', $completedUserIds)
                ->values();
        } else {
            // Student view: Load questions and options but hide is_correct
            $quiz->load(['questions' => function ($q) {
                $q->with(['options' => function ($o) {
                    $o->select(['id', 'quiz_question_id', 'content']); // Exclude is_correct
                }]);
            }]);
        }

        return response()->json($quiz);
    }

    // Create a new quiz (Tutor only)
    public function store(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'tutor') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validator = $this->validateQuizPayload($request);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($courseError = $this->assertTutorOwnsCourse($request)) {
            return $courseError;
        }

        try {
            DB::beginTransaction();

            // Create Quiz
            $quiz = Quiz::create([
                'tutor_id' => $user->id,
                'course_id' => $request->course_id,
                'student_id' => $request->student_id,
                'study_group_id' => $request->study_group_id,
                'title' => $request->title,
                'description' => $request->description,
                'time_limit_minutes' => $request->time_limit_minutes ?? $request->time_limit,
                'is_published' => $request->is_published ?? false,
            ]);

            // Create Questions & Options
            foreach ($request->questions as $qData) {
                $question = $quiz->questions()->create([
                    'content' => $qData['content'],
                    'points' => $qData['points'] ?? 1,
                ]);

                foreach ($qData['options'] as $oData) {
                    $question->options()->create([
                        'content' => $oData['content'],
                        'is_correct' => $oData['is_correct'],
                    ]);
                }
            }

            DB::commit();
            return response()->json($quiz->load('questions.options'), 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to create quiz: ' . $e->getMessage()], 500);
        }
    }

    public function update($id, Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'tutor') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $quiz = Quiz::with('questions.options')->findOrFail($id);
        if ($quiz->tutor_id !== $user->id) {
            return response()->json(['message' => 'Bạn không có quyền sửa bài kiểm tra này.'], 403);
        }

        $validator = $this->validateQuizPayload($request, true);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($courseError = $this->assertTutorOwnsCourse($request)) {
            return $courseError;
        }

        try {
            DB::beginTransaction();

            $quiz->fill($request->only(['title', 'course_id', 'student_id', 'study_group_id', 'description', 'is_published']));
            if ($request->has('time_limit_minutes') || $request->has('time_limit')) {
                $quiz->time_limit_minutes = $request->time_limit_minutes ?? $request->time_limit;
            }
            $quiz->save();

            if ($request->has('questions')) {
                foreach ($quiz->questions as $question) {
                    $question->options()->delete();
                }
                $quiz->questions()->delete();

                foreach ($request->questions as $qData) {
                    $question = $quiz->questions()->create([
                        'content' => $qData['content'],
                        'points' => $qData['points'] ?? 1,
                    ]);

                    foreach ($qData['options'] as $oData) {
                        $question->options()->create([
                            'content' => $oData['content'],
                            'is_correct' => $oData['is_correct'],
                        ]);
                    }
                }
            }

            DB::commit();
            return response()->json($quiz->fresh()->load('questions.options'));
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to update quiz: ' . $e->getMessage()], 500);
        }
    }

    public function destroy($id, Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'tutor' && $user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $quiz = Quiz::findOrFail($id);
        if ($user->role !== 'admin' && $quiz->tutor_id !== $user->id) {
            return response()->json(['message' => 'Bạn không có quyền xóa bài kiểm tra này.'], 403);
        }

        $quiz->delete();
        return response()->json(['message' => 'Đã xóa bài kiểm tra.']);
    }

    // Submit quiz answers (Student)
    public function submit($id, Request $request)
    {
        $user = $request->user();
        $quiz = Quiz::findOrFail($id);

        // Validate
        $request->validate([
            'answers' => 'required|array', // [{'question_id': 1, 'option_id': 2}]
            'answers.*.question_id' => 'required|integer|exists:quiz_questions,id',
            'answers.*.option_id' => 'required|integer|exists:quiz_options,id',
        ]);

        $score = 0;
        $totalPoints = 0;
        $correctAnswers = [];
        $selectedAnswers = [];

        // Load all questions with correct options for grading
        $questions = $quiz->questions()->with('options')->get();

        foreach ($questions as $question) {
            $totalPoints += $question->points;
            
            // Find student's answer for this question
            $studentAnswer = collect($request->answers)->firstWhere('question_id', $question->id);
            $correctOption = $question->options->where('is_correct', true)->first();
            $correctAnswers[$question->id] = $correctOption ? $correctOption->id : null;
            
            // Logic for grading
            // Assuming single choice for now: if option_id matches a correct option
            if ($studentAnswer) {
                $selectedOptionId = $studentAnswer['option_id'];
                $selectedAnswers[$question->id] = $selectedOptionId;
                
                if ($correctOption && $correctOption->id == $selectedOptionId) {
                    $score += $question->points;
                }
            }
        }

        // Record attempt
        $attempt = QuizAttempt::create([
            'user_id' => $user->id,
            'quiz_id' => $quiz->id,
            'score' => $score,
            'started_at' => now(), // Ideally passed from frontend or tracked earlier
            'completed_at' => now(),
        ]);

        return response()->json([
            'score' => $score,
            'total_points' => $totalPoints,
            'attempt_id' => $attempt->id,
            'correct_answers' => $correctAnswers, // Map of question_id -> correct_option_id
            'selected_answers' => $selectedAnswers, // Map of question_id -> selected_option_id
        ]);
    }

    // Get attempts history
    public function attempts(Request $request)
    {
        $user = $request->user();
        $attempts = QuizAttempt::where('user_id', $user->id)
            ->with('quiz')
            ->latest()
            ->get();
            
        return response()->json($attempts);
    }
}

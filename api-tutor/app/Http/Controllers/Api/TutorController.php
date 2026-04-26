<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tutor;
use App\Models\TutorMaterial;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class TutorController extends Controller
{
    public function index(Request $request)
    {
        $query = Tutor::query()->with('user.badges');

        // 1. Featured
        if ($request->has('featured') && $request->featured == 1) {
            return $query->where('rating', '>=', 4.5)->limit(5)->get();
        }

        // 2. Text Search (Name or Subjects)
        if ($request->has('search') && $request->search != null) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('subjects', 'like', "%{$search}%");
            });
        }

        // 3. Filter by Subject (Exact or Like)
        if ($request->has('subjects') && $request->subjects != null) {
            $subjects = explode(',', $request->subjects);
            $query->where(function ($q) use ($subjects) {
                foreach ($subjects as $subject) {
                    $q->orWhere('subjects', 'like', '%"' . $subject . '"%');
                    $q->orWhere('subjects', 'like', "%{$subject}%");
                }
            });
        }

        // 4. Filter by Price
        if ($request->has('min_price')) {
            $query->where('hourly_rate', '>=', $request->min_price);
        }
        if ($request->has('max_price')) {
            $query->where('hourly_rate', '<=', $request->max_price);
        }

        // 5. Filter by Teaching Mode (JSON)
        if ($request->has('mode')) {
            $modes = explode(',', $request->mode);
            $query->where(function ($q) use ($modes) {
                foreach ($modes as $mode) {
                    $q->orWhere('teaching_mode', 'like', "%{$mode}%");
                }
            });
        }

        // 6. Gender
        if ($request->has('gender') && $request->gender != 'Bất kỳ') {
            $query->where('gender', $request->gender);
        }

        // 7. Location
        if ($request->has('location')) {
            $query->where('location', 'like', "%{$request->location}%");
        }

        // 8. Min Rating
        if ($request->has('min_rating') && $request->min_rating != null) {
            $query->where('rating', '>=', $request->min_rating);
        }

        // 9. Degrees
        if ($request->has('degrees') && $request->degrees != null) {
            $degrees = explode(',', $request->degrees);
            $query->where(function ($q) use ($degrees) {
                foreach ($degrees as $degree) {
                    if ($degree == 'Sinh viên') {
                        $q->orWhere('tier', 'student');
                    } elseif ($degree == 'Giáo viên') {
                        $q->orWhere('tier', 'teacher')
                          ->orWhere('degree', 'like', '%Giáo viên%');
                    } else {
                        $q->orWhere('degree', 'like', "%{$degree}%");
                    }
                }
            });
        }

        $tutors = $query->get();

        if ($user = $request->user('sanctum')) {
            $favoriteTutorIds = DB::table('user_favorite_tutors')
                ->where('user_id', $user->id)
                ->pluck('tutor_id')
                ->toArray();
                
            $tutors = $tutors->map(function ($tutor) use ($favoriteTutorIds) {
                $data = $tutor->toArray();
                $data['is_favorite'] = in_array($tutor->id, $favoriteTutorIds);
                return $data;
            });
        }

        return response()->json($tutors);
    }

    public function show(Request $request, $id)
    {
        $tutor = Tutor::with('user.badges')->find($id);
        
        if (!$tutor) {
            return response()->json(['message' => 'Tutor not found'], 404);
        }

        $data = $tutor->toArray();
        $data['is_favorite'] = false;

        if ($user = $request->user('sanctum')) {
            $data['is_favorite'] = DB::table('user_favorite_tutors')
                ->where('user_id', $user->id)
                ->where('tutor_id', $id)
                ->exists();
        }

        return response()->json($data);
    }

    public function getAvailability(Request $request, $id)
    {
        $tutor = Tutor::findOrFail($id);
        return response()->json($tutor->availabilities);
    }

    public function updateAvailability(Request $request)
    {
        $user = $request->user();
        $tutor = Tutor::where('user_id', $user->id)->firstOrFail();

        $request->validate([
            'availabilities' => 'present|array',
            'availabilities.*.day_of_week' => 'required|integer|between:2,8',
            'availabilities.*.start_time' => 'required',
            'availabilities.*.end_time' => 'required',
        ]);

        $tutor->availabilities()->delete();

        $scheduleForJson = [];

        foreach ($request->availabilities as $slot) {
            $tutor->availabilities()->create([
                'day_of_week' => $slot['day_of_week'],
                'start_time' => $slot['start_time'],
                'end_time' => $slot['end_time'],
                'is_recurring' => true 
            ]);

            $day = (string)$slot['day_of_week'];
            $start = substr($slot['start_time'], 0, 5);
            $end = substr($slot['end_time'], 0, 5);
            $timeSlot = "$start - $end";

            if (!isset($scheduleForJson[$day])) {
                $scheduleForJson[$day] = [];
            }
            $scheduleForJson[$day][] = $timeSlot;
        }

        $tutor->weekly_schedule = $scheduleForJson;
        $tutor->save();

        return response()->json(['message' => 'Availability updated', 'availabilities' => $tutor->availabilities]);
    }

    public function getMyAvailability(Request $request) {
        $user = $request->user();
        $tutor = Tutor::where('user_id', $user->id)->firstOrFail();
        return response()->json($tutor->availabilities);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        $tutor = Tutor::where('user_id', $user->id)->firstOrFail();

        $validated = $request->validate([
            'bio' => 'nullable|string',
            'hourly_rate' => 'nullable|numeric',
            'subjects' => 'nullable|array',
            'location' => 'nullable|string',
            'teaching_mode' => 'nullable|array',
            'university' => 'nullable|string',
            'degree' => 'nullable|string',
            'phone' => 'nullable|string',
        ]);

        $tutor->update($validated);

        return response()->json(['message' => 'Profile updated successfully', 'tutor' => $tutor]);
    }

    public function listMaterials(Request $request)
    {
        $user = $request->user();
        $query = TutorMaterial::query();

        if ($user->role === 'tutor') {
            $query->where('tutor_id', $user->id);
        } else {
            // Student filtering: must be explicitly assigned to them, part of a course, or part of a study group.
            $courseIds = DB::table('course_students')->where('user_id', $user->id)->pluck('course_id');
            $studyGroupIds = DB::table('study_group_members')
                ->where('user_id', $user->id)
                ->whereIn('status', ['approved', 'member'])
                ->pluck('study_group_id');
            
            $query->where(function($q) use ($user, $courseIds, $studyGroupIds) {
                $q->where('student_id', $user->id)
                  ->orWhereIn('course_id', $courseIds)
                  ->orWhereIn('study_group_id', $studyGroupIds);
            });
        }

        if ($request->has('course_id')) {
            $query->where('course_id', $request->course_id);
        }

        if ($request->has('student_id')) {
            $query->where('student_id', $request->student_id);
        }

        if ($request->has('study_group_id')) {
            $query->where('study_group_id', $request->study_group_id);
        }

        $materials = $query->latest()->get();
        return response()->json($materials);
    }

    public function uploadMaterial(Request $request)
    {
        $user = $request->user();
        
        $request->validate([
            'material' => 'required|file|max:10240', // 10MB limit
        ]);

        $file = $request->file('material');
        $path = $file->store('tutor_materials', 'public');

        $material = TutorMaterial::create([
            'tutor_id' => $user->id,
            'course_id' => $request->course_id,
            'student_id' => $request->student_id,
            'study_group_id' => $request->study_group_id,
            'name' => $file->getClientOriginalName(),
            'file_path' => $path,
            'file_type' => $file->getClientOriginalExtension(),
            'file_size' => $this->formatBytes($file->getSize()),
        ]);

        return response()->json($material);
    }

    public function deleteMaterial(Request $request, $id)
    {
        $user = $request->user();
        $material = TutorMaterial::where('tutor_id', $user->id)->findOrFail($id);

        Storage::disk('public')->delete($material->file_path);
        $material->delete();

        return response()->json(['message' => 'Material deleted successfully']);
    }

    public function updateMaterial(Request $request, $id)
    {
        $user = $request->user();
        $material = TutorMaterial::where('tutor_id', $user->id)->findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'course_id' => 'nullable|integer|exists:courses,id',
            'student_id' => 'nullable|integer|exists:users,id',
        ]);

        $material->update($validated);

        return response()->json($material->fresh());
    }

    private function formatBytes($bytes, $precision = 2) {
        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        $bytes = max($bytes, 0);
        $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
        $pow = min($pow, count($units) - 1);
        $bytes /= pow(1024, $pow);
        return round($bytes, $precision) . ' ' . $units[$pow];
    }

    public function toggleFavorite(Request $request, $id)
    {
        $user = $request->user();
        if (!$user || $user->role !== 'student') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $existing = DB::table('user_favorite_tutors')
            ->where('user_id', $user->id)
            ->where('tutor_id', $id)
            ->first();

        if ($existing) {
            DB::table('user_favorite_tutors')->where('id', $existing->id)->delete();
            return response()->json(['message' => 'Đã bỏ yêu thích', 'is_favorite' => false]);
        } else {
            DB::table('user_favorite_tutors')->insert([
                'user_id' => $user->id,
                'tutor_id' => $id,
                'created_at' => now(),
                'updated_at' => now()
            ]);
            return response()->json(['message' => 'Đã thêm vào danh sách yêu thích', 'is_favorite' => true]);
        }
    }

    public function getFavorites(Request $request)
    {
        $user = $request->user();
        if (!$user || $user->role !== 'student') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $favoriteTutorIds = DB::table('user_favorite_tutors')
            ->where('user_id', $user->id)
            ->pluck('tutor_id')
            ->toArray();

        $tutors = Tutor::with('user.badges')->whereIn('id', $favoriteTutorIds)->get();
        
        $tutors->each(function ($tutor) {
            $tutor->is_favorite = true;
        });

        return response()->json($tutors);
    }

    public function myStatistics(Request $request)
    {
        $user = $request->user();
        $tutor = Tutor::where('user_id', $user->id)->firstOrFail();

        $bookingRevenue = DB::table('bookings')
            ->where('tutor_id', $tutor->id)
            ->where('status', 'completed')
            ->sum('total_price');

        $walletEarnings = DB::table('transactions')
            ->join('wallets', 'transactions.wallet_id', '=', 'wallets.id')
            ->where('wallets.user_id', $user->id)
            ->where('transactions.type', 'earning')
            ->where('transactions.status', 'success')
            ->sum('transactions.amount');

        $totalRevenue = (float) $bookingRevenue + (float) $walletEarnings;

        $activeBookings = DB::table('bookings')
            ->where('tutor_id', $tutor->id)
            ->whereIn('status', ['upcoming', 'confirmed'])
            ->count();

        $activeCourses = DB::table('courses')
            ->where('tutor_id', $tutor->id)
            ->whereIn('status', ['open', 'full'])
            ->count();

        $activeClasses = $activeBookings + $activeCourses;

        $bookingStudentIds = DB::table('bookings')
            ->where('tutor_id', $tutor->id)
            ->whereIn('status', ['completed', 'upcoming', 'confirmed'])
            ->pluck('student_id')
            ->toArray();

        $courseStudentIds = DB::table('course_students')
            ->join('courses', 'course_students.course_id', '=', 'courses.id')
            ->where('courses.tutor_id', $tutor->id)
            ->where('course_students.status', 'approved')
            ->pluck('course_students.user_id')
            ->toArray();

        $totalStudents = count(array_unique(array_merge($bookingStudentIds, $courseStudentIds)));

        $completedSessions = DB::table('bookings')
            ->where('tutor_id', $tutor->id)
            ->where('status', 'completed')
            ->count();

        $totalProcessed = DB::table('bookings')
            ->where('tutor_id', $tutor->id)
            ->whereIn('status', ['confirmed', 'completed', 'rejected'])
            ->count();
        
        $accepted = DB::table('bookings')
            ->where('tutor_id', $tutor->id)
            ->whereIn('status', ['confirmed', 'completed'])
            ->count();
            
        $bookingRate = $totalProcessed > 0 ? round(($accepted / $totalProcessed) * 100) : 100;

        return response()->json([
            'total_revenue' => $totalRevenue,
            'active_classes' => $activeClasses,
            'total_students' => $totalStudents,
            'teaching_hours' => $completedSessions * 1.5,
            'completed_sessions' => $completedSessions,
            'rating' => $tutor->rating,
            'review_count' => $tutor->review_count,
            'location' => $tutor->location ?? 'Chưa cập nhật',
            'booking_rate' => $bookingRate,
            'completion_rate' => 95,
            'response_time' => '15p'
        ]);
    }

    public function myTuitions(Request $request)
    {
        $user = $request->user();
        $tutor = Tutor::where('user_id', $user->id)->firstOrFail();

        $tutorIds = [$tutor->id, $user->id];

        $bookings = \App\Models\Booking::with(['student', 'tutor'])
            ->whereIn('tutor_id', $tutorIds)
            ->orderBy('start_time', 'desc')
            ->get();

        return response()->json($bookings);
    }
}

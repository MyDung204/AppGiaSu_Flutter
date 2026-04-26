<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TutorController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SharedLearningController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\QuizController;
use App\Http\Controllers\Api\SmartMatchingController;
use App\Http\Controllers\Api\MapController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\VerificationController;
use App\Http\Controllers\Api\TutorRequestController;
use App\Http\Controllers\Api\AdminFinanceController;
use App\Http\Controllers\Api\AdminSystemController;
use App\Http\Controllers\Api\SmartMatchController;
use App\Http\Controllers\Api\CommunityController;

// Public Routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/study-groups', [SharedLearningController::class, 'indexGroups']);
Route::get('/courses', [SharedLearningController::class, 'indexCourses']);
Route::get('/study-groups/{id}/members', [SharedLearningController::class, 'getGroupMembers']);

Route::get('/tutors', [TutorController::class, 'index']);
Route::get('/tutors/{id}', [TutorController::class, 'show'])->where('id', '[0-9]+');
Route::get('/tutors/{id}/availability', [TutorController::class, 'getAvailability'])->where('id', '[0-9]+');

Route::get('/questions', [QuestionController::class, 'index']);
Route::post('/questions', [QuestionController::class, 'store']);
Route::post('/questions/{id}/answers', [QuestionController::class, 'storeAnswer']);

Route::get('/tutor-requests', [TutorRequestController::class, 'index']);

// Protected Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/device-token', [AuthController::class, 'updateDeviceToken']);

    // Shared Learning
    Route::get('/my-study-groups', [SharedLearningController::class, 'myStudyGroups']);
    Route::post('/courses', [SharedLearningController::class, 'storeCourse']);
    Route::put('/courses/{id}', [SharedLearningController::class, 'updateCourse']);
    Route::delete('/courses/{id}', [SharedLearningController::class, 'deleteCourse']);
    Route::post('/courses/{id}/join', [SharedLearningController::class, 'joinCourse']);
    Route::post('/courses/{id}/leave', [SharedLearningController::class, 'leaveCourse']);
    Route::post('/courses/{id}/kick', [SharedLearningController::class, 'removeStudentFromCourse']);
    Route::post('/courses/{id}/tuition/refuse', [SharedLearningController::class, 'refuseTuition']);
    Route::get('/my-courses', [SharedLearningController::class, 'myCourses']);
    
    Route::post('/study-groups', [SharedLearningController::class, 'storeGroup']);
    Route::put('/study-groups/{id}', [SharedLearningController::class, 'updateGroup']);
    Route::delete('/study-groups/{id}', [SharedLearningController::class, 'deleteGroup']);
    Route::post('/study-groups/{id}/join', [SharedLearningController::class, 'joinGroup']);
    Route::post('/study-groups/{id}/members/{userId}/approve', [SharedLearningController::class, 'approveMember']);
    Route::post('/study-groups/{id}/members/{userId}/reject', [SharedLearningController::class, 'rejectMember']);
    Route::delete('/study-groups/{id}/members/{userId}', [SharedLearningController::class, 'removeMember']);
    Route::post('/study-groups/{id}/leave', [SharedLearningController::class, 'leaveGroup']);
    Route::post('/study-groups/{id}/pay', [SharedLearningController::class, 'payGroupTuition']);

    // Announcements
    Route::get('/courses/{id}/announcements', [SharedLearningController::class, 'indexAnnouncements']);
    Route::post('/courses/{id}/announcements', [SharedLearningController::class, 'storeAnnouncement']);

    // Tutors & Availability
    Route::post('/tutors/{id}/favorite', [TutorController::class, 'toggleFavorite']);
    Route::get('/favorites/tutors', [TutorController::class, 'getFavorites']);
    Route::get('/tutors/my-availability', [TutorController::class, 'getMyAvailability']);
    Route::post('/tutors/availability', [TutorController::class, 'updateAvailability']);
    Route::post('/tutors/update-profile', [TutorController::class, 'updateProfile']);
    Route::get('/tutors/my-statistics', [TutorController::class, 'myStatistics']);
    Route::get('/tutors/my-tuitions', [TutorController::class, 'myTuitions']);

    // Materials
    Route::get('/tutors/materials', [TutorController::class, 'listMaterials']);
    Route::post('/tutors/upload-material', [TutorController::class, 'uploadMaterial']);
    Route::put('/tutors/materials/{id}', [TutorController::class, 'updateMaterial']);
    Route::delete('/tutors/materials/{id}', [TutorController::class, 'deleteMaterial']);

    // Bookings
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings/lock', [BookingController::class, 'lockSlot']);
    Route::post('/bookings/{id}/confirm', [BookingController::class, 'confirm']);
    Route::post('/bookings/{id}/reject', [BookingController::class, 'reject']);
    Route::post('/bookings/{id}/cancel', [BookingController::class, 'cancel']);
    Route::post('/bookings/{id}/session-info', [BookingController::class, 'updateSessionInfo']);

    // Chat
    Route::get('/conversations', [ChatController::class, 'index']);
    Route::get('/conversations/{id}/messages', [ChatController::class, 'show']);
    Route::post('/messages', [ChatController::class, 'store']);
    Route::post('/chat/upload', [ChatController::class, 'upload']);
    Route::post('/chat/offer/accept', [ChatController::class, 'acceptOffer']);

    // Wallet
    Route::get('/wallet', [WalletController::class, 'index']);
    Route::post('/wallet/deposit', [WalletController::class, 'deposit']);
    Route::post('/wallet/withdraw', [WalletController::class, 'withdraw']);
    Route::post('/wallet/pin/setup', [WalletController::class, 'setupPin']);
    Route::post('/wallet/pin/change', [WalletController::class, 'changePin']);
    Route::post('/wallet/pin/verify', [WalletController::class, 'verifyPin']);

    // Tutor Requests
    Route::post('/tutor-requests', [TutorRequestController::class, 'store']);
    Route::get('/my-tutor-requests', [TutorRequestController::class, 'myRequests']);
    Route::delete('/tutor-requests/{id}', [TutorRequestController::class, 'destroy']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

    // Assignments
    Route::get('/assignments', [AssignmentController::class, 'index']);
    Route::post('/assignments', [AssignmentController::class, 'store']);
    Route::put('/assignments/{id}', [AssignmentController::class, 'update']);
    Route::post('/assignments/{id}/submit', [AssignmentController::class, 'submit']);
    Route::get('/assignments/{id}/submissions', [AssignmentController::class, 'submissions']);
    Route::post('/assignments/submissions/{id}/grade', [AssignmentController::class, 'grade']);
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);

    // Quiz System
    Route::get('/quizzes', [QuizController::class, 'index']);
    Route::get('/quizzes/{id}', [QuizController::class, 'show']);
    Route::post('/quizzes', [QuizController::class, 'store']);
    Route::put('/quizzes/{id}', [QuizController::class, 'update']);
    Route::delete('/quizzes/{id}', [QuizController::class, 'destroy']);
    Route::post('/quizzes/{id}/submit', [QuizController::class, 'submit']);
    Route::get('/my-quiz-attempts', [QuizController::class, 'attempts']);

    // Smart Matching
    Route::get('/smart-matching/request/{id}', [SmartMatchingController::class, 'matchTutorsForRequest']);
    Route::get('/smart-matching/tutor', [SmartMatchingController::class, 'matchRequestsForTutor']);

    // Map System
    Route::post('/map/update-location', [MapController::class, 'updateLocation']);
    Route::get('/map/nearby', [MapController::class, 'getNearbyUsers']);

    // Verification (eKYC)
    Route::post('/verification/submit', [VerificationController::class, 'submit']);
    Route::get('/verification/status', [VerificationController::class, 'getStatus']);
    Route::post('/verification/{id}/approve', [VerificationController::class, 'approve']);
    Route::post('/verification/{id}/reject', [VerificationController::class, 'reject']);
    Route::get('/verification/pending', [VerificationController::class, 'listPending']);

    // Payment Simulation
    Route::post('/payment/simulate', [PaymentController::class, 'simulate']);
});

// Admin Routes
Route::prefix('admin')->middleware(['auth:sanctum'])->group(function () {
    Route::get('/stats', [AdminController::class, 'stats']);
    Route::get('/users', [AdminController::class, 'users']);
    Route::get('/users/{id}', [AdminController::class, 'showUser']);
    Route::put('/users/{id}', [AdminController::class, 'updateUser']);
    Route::get('/users/{id}/activities', [AdminController::class, 'getUserActivities']);
    Route::post('/users/{id}/ban', [AdminController::class, 'toggleBan']);

    Route::post('/smart-match', [SmartMatchController::class, 'getMatches']);
    Route::post('/user/learning-tags', [SmartMatchController::class, 'saveTags']);

    Route::apiResource('community-questions', CommunityController::class)->only(['index', 'store', 'show']);
    Route::post('/community-questions/{id}/answers', [CommunityController::class, 'storeAnswer']);

    Route::get('/tutor-requests', [AdminController::class, 'tutorRequests']);
    Route::post('/tutors/{id}/approve', [AdminController::class, 'approveTutor']);
    Route::post('/tutors/{id}/reject', [AdminController::class, 'rejectTutor']);

    Route::get('/reports', [AdminController::class, 'reports']);
    Route::post('/reports/{id}/resolve', [AdminController::class, 'resolveReport']);

    Route::get('/audit-logs', [AdminController::class, 'getAuditLogs']);

    Route::get('/courses/pending', [AdminController::class, 'pendingCourses']);
    Route::post('/courses/{id}/approve', [AdminController::class, 'approveCourse']);
    Route::post('/courses/{id}/reject', [AdminController::class, 'rejectCourse']);

    Route::post('/notifications/broadcast', [AdminController::class, 'broadcast']);

    Route::get('/withdrawals', [AdminFinanceController::class, 'index']);
    Route::post('/withdrawals/{id}/approve', [AdminFinanceController::class, 'approve']);
    Route::post('/withdrawals/{id}/reject', [AdminFinanceController::class, 'reject']);

    Route::get('/system/subjects', [AdminSystemController::class, 'subjects']);
    Route::post('/system/subjects', [AdminSystemController::class, 'storeSubject']);
    Route::put('/system/subjects/{id}', [AdminSystemController::class, 'updateSubject']);
    Route::delete('/system/subjects/{id}', [AdminSystemController::class, 'destroySubject']);
});

// Test/Webhook Routes
Route::post('/send-notification', function (Illuminate\Http\Request $request, App\Services\FirebaseNotificationService $service) {
    $request->validate([
        'user_id' => 'required',
        'title' => 'required',
        'body' => 'required',
    ]);
    $service->sendToUser($request->user_id, $request->title, $request->body, $request->input('type', 'system'), $request->input('data', []));
    return response()->json(['message' => 'Notification sent']);
});

Route::post('/payment/webhook', [PaymentController::class, 'webhook']);

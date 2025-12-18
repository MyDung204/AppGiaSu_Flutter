<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TutorController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\SharedLearningController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->get('/user', [AuthController::class, 'me']);

Route::get('/debug-tutors', function () {
    return \App\Models\Tutor::all();
});

// Shared Learning
Route::get('/study-groups', [SharedLearningController::class, 'indexGroups']);
Route::get('/courses', [SharedLearningController::class, 'indexCourses']);
Route::middleware('auth:sanctum')->post('/study-groups', [SharedLearningController::class, 'storeGroup']);

Route::get('/tutors', [TutorController::class, 'index']);
Route::get('/tutors/{id}', [TutorController::class, 'show']);
Route::get('/questions', [QuestionController::class, 'index']);
Route::post('/questions', [QuestionController::class, 'store']);
Route::post('/questions/{id}/answers', [QuestionController::class, 'storeAnswer']);
Route::get('/bookings', [BookingController::class, 'index']);
Route::post('/bookings/lock', [BookingController::class, 'lockSlot']);
Route::post('/bookings/{id}/confirm', [BookingController::class, 'confirm']);
Route::post('/bookings/{id}/cancel', [BookingController::class, 'cancel']);

// Chat
Route::get('/conversations', [App\Http\Controllers\Api\ChatController::class, 'index']);
Route::get('/conversations/{id}/messages', [App\Http\Controllers\Api\ChatController::class, 'show']);
Route::post('/messages', [App\Http\Controllers\Api\ChatController::class, 'store']);

// Wallet
Route::get('/wallet', [App\Http\Controllers\Api\WalletController::class, 'index']);
Route::post('/wallet/deposit', [App\Http\Controllers\Api\WalletController::class, 'deposit']);

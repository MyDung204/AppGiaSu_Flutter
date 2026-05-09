<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Tutor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role ?? 'student'
        ]);

        if ($user->role === 'tutor') {
            Tutor::create([
                'user_id' => $user->id,
                'name' => $user->name,
                'hourly_rate' => 0,
                'rating' => 0,
                'subjects' => [],
                'teaching_mode' => [],
                'location' => '',
                'is_verified' => false
            ]);
        }

        return response()->json(['token' => $user->createToken('auth')->plainTextToken, 'user' => $user]);
    }
    public function login(Request $request, \App\Services\FirebaseNotificationService $notificationService)
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json(['message' => 'Invalid'], 401);
        }

        $user = User::where('email', $request->email)->first();
        $token = $user->createToken('auth')->plainTextToken;

        // Send Login Notification
        $notificationService->sendToUser(
            $user->id,
            'Đăng nhập mới',
            'Tài khoản của bạn vừa đăng nhập vào thiết bị mới.',
            'security'
        );

        return response()->json(['token' => $token, 'user' => $user->load('tutorProfile')]);
    }
    public function me(Request $request)
    {
        return $request->user()->load('tutorProfile'); // Load tutor profile relation
    }
    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'new_password' => 'required|min:6|confirmed'
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json(['message' => 'Mật khẩu hiện tại không đúng'], 400);
        }

        $user->update(['password' => Hash::make($request->new_password)]);

        return response()->json(['message' => 'Đổi mật khẩu thành công']);
    }

    public function updateDeviceToken(Request $request)
    {
        $request->validate(['token' => 'required|string']);
        $request->user()->update(['device_token' => $request->token]);
        return response()->json(['message' => 'Device token updated']);
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:100',
            'avatar' => 'nullable|image|max:2048',
            'remove_avatar' => 'nullable|boolean',
        ]);

        $user = $request->user();
        $user->name = $request->name;

        if ($request->boolean('remove_avatar')) {
            if ($user->avatar_url && str_contains($user->avatar_url, '/storage/')) {
                $oldPath = ltrim(parse_url($user->avatar_url, PHP_URL_PATH) ?? '', '/');
                $oldPath = str_replace('storage/', '', $oldPath);
                if ($oldPath !== '') {
                    Storage::disk('public')->delete($oldPath);
                }
            }
            $user->avatar_url = null;
        }

        if ($request->hasFile('avatar')) {
            if ($user->avatar_url && str_contains($user->avatar_url, '/storage/')) {
                $oldPath = ltrim(parse_url($user->avatar_url, PHP_URL_PATH) ?? '', '/');
                $oldPath = str_replace('storage/', '', $oldPath);
                if ($oldPath !== '') {
                    Storage::disk('public')->delete($oldPath);
                }
            }

            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar_url = url('/storage/' . $path);
        }

        $user->save();

        if ($user->role === 'tutor') {
            $tutor = Tutor::where('user_id', $user->id)->first();
            if ($tutor) {
                $tutor->name = $user->name;
                $tutor->avatar_url = $user->avatar_url;
                $tutor->save();
            }
        }

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $user->fresh()->load('tutorProfile'),
        ]);
    }
}

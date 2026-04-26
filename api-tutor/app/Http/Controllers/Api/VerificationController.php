<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tutor;
use App\Models\VerificationRequest;
use Illuminate\Http\Request;

class VerificationController extends Controller
{
    public function submit(Request $request)
    {
        $user = $request->user();

        $existing = VerificationRequest::where('user_id', $user->id)
            ->where('status', 'pending')
            ->first();
        if ($existing) {
            return response()->json(['message' => 'Ban dang co yeu cau cho duyet.'], 400);
        }

        $request->validate([
            'front_image' => 'nullable|image|max:5120',
            'back_image' => 'nullable|image|max:5120',
            'front_image_url' => 'nullable|string',
            'back_image_url' => 'nullable|string',
        ]);

        $frontImageUrl = $this->storeVerificationImage($request, 'front_image')
            ?? $request->front_image_url;
        $backImageUrl = $this->storeVerificationImage($request, 'back_image')
            ?? $request->back_image_url;

        if (!$frontImageUrl) {
            return response()->json(['message' => 'Vui long tai len anh xac thuc.'], 422);
        }

        $verification = VerificationRequest::create([
            'user_id' => $user->id,
            'type' => $user->role === 'tutor' ? 'tutor_card' : 'student_card',
            'front_image_url' => $frontImageUrl,
            'back_image_url' => $backImageUrl,
            'status' => 'pending',
        ]);

        return response()->json($verification, 201);
    }

    public function getStatus(Request $request)
    {
        $latest = VerificationRequest::where('user_id', $request->user()->id)
            ->latest()
            ->first();

        return response()->json($latest);
    }

    public function approve($id)
    {
        $req = VerificationRequest::findOrFail($id);

        if ($req->status !== 'pending') {
            return response()->json(['message' => 'Request is not pending'], 400);
        }

        $req->update(['status' => 'approved']);
        $req->user->update(['identity_verified_at' => now()]);

        $tutor = Tutor::where('user_id', $req->user_id)->first();
        if ($tutor) {
            $tutor->update(['is_verified' => true]);
        }

        return response()->json(['message' => 'Approved successfully']);
    }

    public function reject(Request $request, $id)
    {
        $req = VerificationRequest::findOrFail($id);

        $req->update([
            'status' => 'rejected',
            'note' => $request->note ?? 'Ho so khong hop le.',
        ]);

        return response()->json(['message' => 'Rejected successfully']);
    }

    public function listPending()
    {
        return VerificationRequest::with('user')->where('status', 'pending')->get();
    }

    public function file($filename)
    {
        $filename = basename($filename);
        $path = storage_path('app/public/verification/' . $filename);

        if (!file_exists($path)) {
            abort(404);
        }

        return response()->file($path);
    }

    private function storeVerificationImage(Request $request, string $field): ?string
    {
        if (!$request->hasFile($field)) {
            return null;
        }

        $path = $request->file($field)->store('verification', 'public');

        return '/api/verification/file/' . basename($path);
    }
}

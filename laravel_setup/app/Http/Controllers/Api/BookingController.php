<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Carbon\Carbon;

class BookingController extends Controller
{
    public function index()
    {
        return Booking::latest()->get();
    }
    public function lockSlot(Request $request)
    {
        $exists = Booking::where('tutor_id', $request->tutor_id)
            ->where('date', $request->date)->where('time_slot', $request->time_slot)
            ->where(function ($q) {
                $q->where('status', 'Upcoming')
                    ->orWhere(function ($sub) {
                        $sub->where('status', 'Locked')->where('locked_until', '>', Carbon::now()); });
            })->exists();
        if ($exists)
            return response()->json(['message' => 'Slot already taken'], 409);

        $booking = Booking::create(array_merge($request->all(), [
            'status' => 'Locked',
            'locked_until' => Carbon::now()->addMinutes(10)
        ]));
        return response()->json($booking, 201);
    }
    public function confirm($id)
    {
        Booking::find($id)->update(['status' => 'Upcoming', 'locked_until' => null]);
        return response()->json(['success' => true]);
    }
}

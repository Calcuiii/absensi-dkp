<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Office;
use App\Models\SiMelayurParticipant;
use App\Models\User;
use Illuminate\Http\Request;

class AdminDashboardController extends Controller
{
    /**
     * Ringkasan Rekap Presensi & Peserta
     */
    public function summary(Request $request)
    {
        $today = now()->toDateString();

        $totalParticipants = SiMelayurParticipant::count();
        $activeParticipants = SiMelayurParticipant::where('is_active', true)->count();

        $todayAttendances = Attendance::where('date', $today)->count();
        $todayValid = Attendance::where('date', $today)->where('check_in_status', 'valid')->count();
        $todayRejected = Attendance::where('date', $today)->where('check_in_status', 'rejected')->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_participants' => $totalParticipants,
                'active_participants' => $activeParticipants,
                'today' => $today,
                'today_presensi_count' => $todayAttendances,
                'today_valid_count' => $todayValid,
                'today_rejected_count' => $todayRejected,
            ],
        ]);
    }

    /**
     * Daftar rekap presensi dengan filter tanggal, peserta, dan status
     */
    public function attendances(Request $request)
    {
        $query = Attendance::with(['user.participant']);

        if ($request->filled('date')) {
            $query->where('date', $request->date);
        }

        if ($request->filled('status')) {
            $query->where('check_in_status', $request->status);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->whereHas('user', function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $attendances = $query->orderBy('created_at', 'desc')->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => $attendances,
        ]);
    }

    /**
     * Pengaturan Geofence / Kantor DKP
     */
    public function updateGeofence(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius_meters' => 'required|integer|min:10',
        ]);

        $office = Office::first();
        if (!$office) {
            $office = new Office();
        }

        $office->name = $request->name;
        $office->latitude = $request->latitude;
        $office->longitude = $request->longitude;
        $office->radius_meters = $request->radius_meters;
        $office->is_active = true;
        $office->save();

        return response()->json([
            'success' => true,
            'message' => 'Pengaturan radius/geofence kantor DKP berhasil diperbarui.',
            'data' => $office,
        ]);
    }

    /**
     * Sinkronisasi data peserta SI-MELAYUR
     */
    public function syncParticipant(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'full_name' => 'required|string',
            'institution' => 'required|string',
            'identification_number' => 'nullable|string',
            'status' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'assigned_division' => 'nullable|string',
        ]);

        $participant = SiMelayurParticipant::updateOrCreate(
            ['email' => strtolower(trim($request->email))],
            $request->only([
                'full_name',
                'institution',
                'identification_number',
                'status',
                'start_date',
                'end_date',
                'assigned_division',
                'is_active',
            ])
        );

        return response()->json([
            'success' => true,
            'message' => 'Data peserta SI-MELAYUR berhasil disinkronkan.',
            'data' => $participant,
        ]);
    }
}

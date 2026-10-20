<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Office;
use App\Services\SiMelayurService;
use Carbon\Carbon;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    protected SiMelayurService $siMelayurService;

    public function __construct(SiMelayurService $siMelayurService)
    {
        $this->siMelayurService = $siMelayurService;
    }

    /**
     * Presensi Masuk (Check-In)
     */
    public function checkIn(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'is_mock' => 'nullable|boolean',
            'notes' => 'nullable|string',
        ]);

        $user = $request->user();

        // 1. Validasi ganda ke SI-MELAYUR (status & periode magang)
        $verification = $this->siMelayurService->verifyParticipant($user->email);
        if (!$verification['allowed']) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak: ' . $verification['message'],
                'error_code' => 'ACCESS_DENIED_SI_MELAYUR',
            ], 403);
        }

        $today = Carbon::today()->toDateString();
        $attendance = Attendance::firstOrNew(['user_id' => $user->id, 'date' => $today]);

        if ($attendance->exists && $attendance->check_in_at !== null) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah melakukan presensi masuk untuk hari ini.',
            ], 400);
        }

        // 2. Validasi Geofencing lokasi kantor DKP
        $office = Office::where('is_active', true)->first();
        $distance = null;
        $isMock = $request->boolean('is_mock');
        $status = 'valid';
        $rejectionReason = null;

        if ($office) {
            $distance = $office->calculateDistanceTo($request->latitude, $request->longitude);
            if ($distance > $office->radius_meters) {
                $status = 'rejected';
                $rejectionReason = "Berada di luar jangkauan area DKP ({$distance} meter, batas radius {$office->radius_meters} meter).";
            }
        }

        // 3. Deteksi Mock Location (GPS Palsu)
        if ($isMock) {
            $status = 'rejected';
            $rejectionReason = ($rejectionReason ? $rejectionReason . ' | ' : '') . 'Terdeteksi menggunakan Fake/Mock Location (Aplikasi GPS Palsu).';
        }

        // Simpan data presensi masuk
        $attendance->check_in_at = now();
        $attendance->check_in_latitude = $request->latitude;
        $attendance->check_in_longitude = $request->longitude;
        $attendance->check_in_distance = $distance;
        $attendance->check_in_is_mock = $isMock;
        $attendance->check_in_status = $status;
        $attendance->notes = $request->notes;
        if ($rejectionReason) {
            $attendance->rejection_reason = $rejectionReason;
        }
        $attendance->save();

        if ($status === 'rejected') {
            return response()->json([
                'success' => false,
                'message' => 'Presensi masuk ditolak: ' . $rejectionReason,
                'data' => $attendance,
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Presensi masuk berhasil dicatat.',
            'data' => $attendance,
        ]);
    }

    /**
     * Presensi Keluar (Check-Out)
     */
    public function checkOut(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'is_mock' => 'nullable|boolean',
            'notes' => 'nullable|string',
        ]);

        $user = $request->user();
        $today = Carbon::today()->toDateString();
        $attendance = Attendance::where('user_id', $user->id)->where('date', $today)->first();

        if (!$attendance || !$attendance->check_in_at) {
            return response()->json([
                'success' => false,
                'message' => 'Anda belum melakukan presensi masuk hari ini.',
            ], 400);
        }

        if ($attendance->check_out_at !== null) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah melakukan presensi keluar untuk hari ini.',
            ], 400);
        }

        // Validasi Geofence & Mock location
        $office = Office::where('is_active', true)->first();
        $distance = null;
        $isMock = $request->boolean('is_mock');
        $status = 'valid';
        $rejectionReason = null;

        if ($office) {
            $distance = $office->calculateDistanceTo($request->latitude, $request->longitude);
            if ($distance > $office->radius_meters) {
                $status = 'rejected';
                $rejectionReason = "Check-out di luar area kantor ({$distance} meter dari kantor).";
            }
        }

        if ($isMock) {
            $status = 'rejected';
            $rejectionReason = ($rejectionReason ? $rejectionReason . ' | ' : '') . 'Terdeteksi menggunakan Fake/Mock Location.';
        }

        $attendance->check_out_at = now();
        $attendance->check_out_latitude = $request->latitude;
        $attendance->check_out_longitude = $request->longitude;
        $attendance->check_out_distance = $distance;
        $attendance->check_out_is_mock = $isMock;
        $attendance->check_out_status = $status;
        if ($rejectionReason) {
            $attendance->rejection_reason = ($attendance->rejection_reason ? $attendance->rejection_reason . '; ' : '') . $rejectionReason;
        }
        $attendance->save();

        if ($status === 'rejected') {
            return response()->json([
                'success' => false,
                'message' => 'Presensi keluar ditolak: ' . $rejectionReason,
                'data' => $attendance,
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => 'Presensi keluar berhasil dicatat.',
            'data' => $attendance,
        ]);
    }

    /**
     * Riwayat presensi peserta
     */
    public function history(Request $request)
    {
        $user = $request->user();

        $attendances = Attendance::where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $attendances,
        ]);
    }

    /**
     * Cek status presensi hari ini
     */
    public function todayStatus(Request $request)
    {
        $user = $request->user();
        $today = Carbon::today()->toDateString();

        $attendance = Attendance::where('user_id', $user->id)
            ->where('date', $today)
            ->first();

        $office = Office::where('is_active', true)->first();

        return response()->json([
            'success' => true,
            'data' => [
                'today' => $today,
                'has_checked_in' => $attendance && $attendance->check_in_at !== null,
                'has_checked_out' => $attendance && $attendance->check_out_at !== null,
                'attendance' => $attendance,
                'office_geofence' => $office,
            ],
        ]);
    }
}

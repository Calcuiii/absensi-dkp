<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'name' => 'Absensi DKP API',
        'status' => 'online',
        'message' => 'Backend API aktif dan siap digunakan.',
        'endpoints' => [
            'google_login' => url('/api/auth/google-login'),
            'admin_summary' => url('/api/admin/summary'),
            'admin_attendances' => url('/api/admin/attendances'),
            'attendance_today' => url('/api/attendance/today'),
            'attendance_history' => url('/api/attendance/history'),
        ],
    ]);
});

<?php

use App\Http\Controllers\Api\AdminDashboardController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - Absensi DKP & SI-MELAYUR
|--------------------------------------------------------------------------
*/

// Auth Endpoint (Google OAuth & Verifikasi SI-MELAYUR)
Route::prefix('auth')->group(function () {
    Route::post('/google-login', [AuthController::class, 'googleLogin']);
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::get('/profile', [AuthController::class, 'profile'])->middleware('auth:sanctum');
});

// Endpoint untuk Peserta Mobile (Flutter)
Route::middleware('auth:sanctum')->prefix('attendance')->group(function () {
    Route::get('/today', [AttendanceController::class, 'todayStatus']);
    Route::post('/check-in', [AttendanceController::class, 'checkIn']);
    Route::post('/check-out', [AttendanceController::class, 'checkOut']);
    Route::get('/history', [AttendanceController::class, 'history']);
});

// Endpoint untuk Dashboard PJ / Admin DKP
Route::prefix('admin')->group(function () {
    Route::get('/summary', [AdminDashboardController::class, 'summary']);
    Route::get('/attendances', [AdminDashboardController::class, 'attendances']);
    Route::post('/geofence', [AdminDashboardController::class, 'updateGeofence']);
    Route::post('/sync-participant', [AdminDashboardController::class, 'syncParticipant']);
});

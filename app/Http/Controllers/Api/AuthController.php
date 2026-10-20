<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\SiMelayurService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    protected SiMelayurService $siMelayurService;

    public function __construct(SiMelayurService $siMelayurService)
    {
        $this->siMelayurService = $siMelayurService;
    }

    /**
     * Login / Integrasi Akun Google Peserta dari Flutter Mobile
     */
    public function googleLogin(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'name' => 'required|string',
            'google_id' => 'nullable|string',
            'avatar' => 'nullable|string',
        ]);

        $email = strtolower(trim($request->email));

        // 1. Verifikasi aturan SI-MELAYUR (status diterima, tanggal periode aktif)
        $verification = $this->siMelayurService->verifyParticipant($email);

        if (!$verification['allowed']) {
            return response()->json([
                'success' => false,
                'message' => $verification['message'],
                'error_code' => 'ACCESS_DENIED_SI_MELAYUR',
            ], $verification['status_code']);
        }

        $participant = $verification['participant'];

        // 2. Hubungkan atau buat user akun di sistem
        $user = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => $participant->full_name ?? $request->name,
                'password' => Hash::make(Str::random(24)),
                'role' => 'peserta',
                'google_id' => $request->google_id,
                'avatar' => $request->avatar,
                'participant_id' => $participant->id,
                'email_verified_at' => now(),
            ]
        );

        // 3. Buat Sanctum API Token untuk Flutter Mobile
        $token = $user->createToken('flutter-mobile-auth')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil dan terverifikasi SI-MELAYUR.',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'avatar' => $user->avatar,
                ],
                'participant_info' => [
                    'institution' => $participant->institution,
                    'identification_number' => $participant->identification_number,
                    'assigned_division' => $participant->assigned_division,
                    'status' => $participant->status,
                    'start_date' => $participant->start_date->format('Y-m-d'),
                    'end_date' => $participant->end_date->format('Y-m-d'),
                ],
            ],
        ]);
    }

    /**
     * Ambil profil peserta & info SI-MELAYUR terkini
     */
    public function profile(Request $request)
    {
        $user = $request->user()->load('participant');

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'participant' => $user->participant,
            ],
        ]);
    }

    /**
     * Logout & Revoke token
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Berhasil logout.',
        ]);
    }
}

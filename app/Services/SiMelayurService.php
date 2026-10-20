<?php

namespace App\Services;

use App\Models\SiMelayurParticipant;
use Carbon\Carbon;

class SiMelayurService
{
    /**
     * Memeriksa dan mencocokkan email Google peserta dengan data SI-MELAYUR
     *
     * @param string $email
     * @return array
     */
    public function verifyParticipant(string $email): array
    {
        $participant = SiMelayurParticipant::where('email', strtolower(trim($email)))->first();

        if (!$participant) {
            return [
                'allowed' => false,
                'status_code' => 403,
                'message' => 'Email Anda tidak terdaftar dalam pangkalan data SI-MELAYUR. Silakan hubungi koordinator DKP.',
                'participant' => null,
            ];
        }

        // Cek status penerimaan
        if (!$participant->isAccepted()) {
            return [
                'allowed' => false,
                'status_code' => 403,
                'message' => 'Status pendaftaran Anda di SI-MELAYUR saat ini bukan diterima (' . $participant->status . ').',
                'participant' => $participant,
            ];
        }

        // Cek status keaktifan umum
        if (!$participant->is_active) {
            return [
                'allowed' => false,
                'status_code' => 403,
                'message' => 'Akun peserta Anda telah dinonaktifkan oleh Administrator.',
                'participant' => $participant,
            ];
        }

        // Cek rentang periode magang/PKL
        $today = Carbon::today();
        $startDate = Carbon::parse($participant->start_date)->startOfDay();
        $endDate = Carbon::parse($participant->end_date)->endOfDay();

        if ($today->lt($startDate)) {
            return [
                'allowed' => false,
                'status_code' => 403,
                'message' => 'Periode magang Anda belum dimulai. Mulai aktif: ' . $startDate->format('d-m-Y'),
                'participant' => $participant,
            ];
        }

        if ($today->gt($endDate)) {
            return [
                'allowed' => false,
                'status_code' => 403,
                'message' => 'Periode magang Anda telah berakhir pada ' . $endDate->format('d-m-Y') . '.',
                'participant' => $participant,
            ];
        }

        return [
            'allowed' => true,
            'status_code' => 200,
            'message' => 'Data peserta terverifikasi di SI-MELAYUR dan aktif.',
            'participant' => $participant,
        ];
    }
}

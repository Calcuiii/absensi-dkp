<?php

namespace Database\Seeders;

use App\Models\Office;
use App\Models\SiMelayurParticipant;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Data Dummy Lokasi Kantor DKP (Geofence Default)
        Office::firstOrCreate(
            ['name' => 'Kantor Dinas Kelautan dan Perikanan'],
            [
                'latitude' => -6.917464, // Contoh titik koordinat DKP
                'longitude' => 107.619122,
                'radius_meters' => 100, // Radius 100 meter
                'is_active' => true,
            ]
        );

        // 2. Data Dummy Peserta SI-MELAYUR yang diterima dan aktif
        $participantActive = SiMelayurParticipant::firstOrCreate(
            ['email' => 'peserta.aktif@gmail.com'],
            [
                'full_name' => 'Peserta Aktif Magang',
                'institution' => 'Universitas / SMK Negeri',
                'identification_number' => '1234567890',
                'status' => 'accepted',
                'start_date' => now()->subDays(10)->toDateString(),
                'end_date' => now()->addDays(60)->toDateString(),
                'assigned_division' => 'Bidang Kelautan & Pesisir',
                'is_active' => true,
            ]
        );

        // Peserta yang periodenya sudah habis (kadaluarsa)
        SiMelayurParticipant::firstOrCreate(
            ['email' => 'peserta.kadaluarsa@gmail.com'],
            [
                'full_name' => 'Peserta Selesai Magang',
                'institution' => 'Universitas Terbuka',
                'identification_number' => '9876543210',
                'status' => 'completed',
                'start_date' => now()->subDays(100)->toDateString(),
                'end_date' => now()->subDays(10)->toDateString(),
                'assigned_division' => 'Bidang Pengawasan',
                'is_active' => false,
            ]
        );

        // 3. User Admin / PJ
        User::firstOrCreate(
            ['email' => 'admin@dkp.go.id'],
            [
                'name' => 'Admin DKP',
                'role' => 'admin',
                'password' => Hash::make('password123'),
            ]
        );
    }
}

<?php

namespace Tests\Feature;

use App\Models\Office;
use App\Models\SiMelayurParticipant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AbsensiBackendTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // 1. Setup Geofence Kantor DKP (Default koordinat: -6.917464, 107.619122 dengan radius 100 meter)
        Office::create([
            'name' => 'Kantor DKP',
            'latitude' => -6.917464,
            'longitude' => 107.619122,
            'radius_meters' => 100,
            'is_active' => true,
        ]);

        // 2. Setup Peserta SI-MELAYUR aktif
        SiMelayurParticipant::create([
            'email' => 'peserta.aktif@gmail.com',
            'full_name' => 'Peserta Uji Coba',
            'institution' => 'Universitas Indonesia',
            'identification_number' => '12345678',
            'status' => 'accepted',
            'start_date' => now()->subDays(5)->toDateString(),
            'end_date' => now()->addDays(30)->toDateString(),
            'is_active' => true,
        ]);

        // 3. Setup Peserta SI-MELAYUR kadaluarsa
        SiMelayurParticipant::create([
            'email' => 'peserta.expired@gmail.com',
            'full_name' => 'Peserta Kadaluarsa',
            'institution' => 'Universitas Lain',
            'identification_number' => '87654321',
            'status' => 'completed',
            'start_date' => now()->subDays(60)->toDateString(),
            'end_date' => now()->subDays(10)->toDateString(),
            'is_active' => false,
        ]);
    }

    /**
     * Test login Google ditolak jika email tidak ada di SI-MELAYUR
     */
    public function test_google_login_rejected_if_not_registered_in_si_melayur(): void
    {
        $response = $this->postJson('/api/auth/google-login', [
            'email' => 'tidak.terdaftar@gmail.com',
            'name' => 'Orang Asing',
        ]);

        $response->assertStatus(403)
                 ->assertJson([
                     'success' => false,
                     'error_code' => 'ACCESS_DENIED_SI_MELAYUR',
                 ]);
    }

    /**
     * Test login Google ditolak jika periode magang sudah berakhir
     */
    public function test_google_login_rejected_if_period_expired(): void
    {
        $response = $this->postJson('/api/auth/google-login', [
            'email' => 'peserta.expired@gmail.com',
            'name' => 'Peserta Kadaluarsa',
        ]);

        $response->assertStatus(403)
                 ->assertJson([
                     'success' => false,
                     'error_code' => 'ACCESS_DENIED_SI_MELAYUR',
                 ]);
    }

    /**
     * Test login Google berhasil untuk peserta aktif SI-MELAYUR dan menghasilkan token
     */
    public function test_google_login_success_for_valid_participant(): void
    {
        $response = $this->postJson('/api/auth/google-login', [
            'email' => 'peserta.aktif@gmail.com',
            'name' => 'Peserta Uji Coba',
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         'token',
                         'user',
                         'participant_info',
                     ],
                 ]);
    }

    /**
     * Test presensi masuk berhasil jika berada di dalam radius kantor DKP
     */
    public function test_check_in_success_inside_geofence(): void
    {
        // Login terlebih dahulu
        $loginRes = $this->postJson('/api/auth/google-login', [
            'email' => 'peserta.aktif@gmail.com',
            'name' => 'Peserta Uji Coba',
        ]);

        $token = $loginRes->json('data.token');

        // Presensi di titik pas koordinat kantor
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson('/api/attendance/check-in', [
                             'latitude' => -6.917464,
                             'longitude' => 107.619122,
                             'is_mock' => false,
                         ]);

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'check_in_status' => 'valid',
                     ],
                 ]);
    }

    /**
     * Test presensi masuk ditolak jika berada di luar radius kantor DKP
     */
    public function test_check_in_rejected_outside_geofence(): void
    {
        $loginRes = $this->postJson('/api/auth/google-login', [
            'email' => 'peserta.aktif@gmail.com',
            'name' => 'Peserta Uji Coba',
        ]);

        $token = $loginRes->json('data.token');

        // Titik lokasi berjarak jauh (di luar 100m)
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson('/api/attendance/check-in', [
                             'latitude' => -6.920000,
                             'longitude' => 107.630000,
                             'is_mock' => false,
                         ]);

        $response->assertStatus(422)
                 ->assertJson([
                     'success' => false,
                 ]);
    }

    /**
     * Test presensi masuk ditolak jika menggunakan Fake GPS / Mock Location
     */
    public function test_check_in_rejected_when_mock_location_detected(): void
    {
        $loginRes = $this->postJson('/api/auth/google-login', [
            'email' => 'peserta.aktif@gmail.com',
            'name' => 'Peserta Uji Coba',
        ]);

        $token = $loginRes->json('data.token');

        // Meskipun di koordinat kantor, tapi is_mock bernilai true
        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
                         ->postJson('/api/attendance/check-in', [
                             'latitude' => -6.917464,
                             'longitude' => 107.619122,
                             'is_mock' => true,
                         ]);

        $response->assertStatus(422)
                 ->assertJson([
                     'success' => false,
                 ]);
    }
}

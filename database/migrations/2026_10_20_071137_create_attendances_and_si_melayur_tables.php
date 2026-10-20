<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Tabel Peserta Magang / PKL SI-MELAYUR
        Schema::create('si_melayur_participants', function (Blueprint $table) {
            $table->id();
            $table->string('email')->unique();
            $table->string('full_name');
            $table->string('institution'); // Asal sekolah / kampus
            $table->string('identification_number')->nullable(); // NIM / NISN
            $table->string('status')->default('accepted'); // accepted, active, completed, rejected
            $table->date('start_date');
            $table->date('end_date');
            $table->string('assigned_division')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // 2. Tambah kolom role & participant id di users jika diperlukan
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default('peserta')->after('email'); // peserta, admin, pj
            $table->foreignId('participant_id')->nullable()->constrained('si_melayur_participants')->nullOnDelete()->after('role');
            $table->string('google_id')->nullable()->after('email');
            $table->string('avatar')->nullable()->after('google_id');
        });

        // 3. Tabel Lokasi Kantor / Titik Geofencing DKP
        Schema::create('offices', function (Blueprint $table) {
            $table->id();
            $table->string('name')->default('Kantor Dinas Kelautan dan Perikanan');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->integer('radius_meters')->default(100); // Radius geofence dalam meter
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // 4. Tabel Presensi Masuk / Keluar
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->timestamp('check_in_at')->nullable();
            $table->timestamp('check_out_at')->nullable();
            
            // Koordinat & validasi check in
            $table->decimal('check_in_latitude', 10, 7)->nullable();
            $table->decimal('check_in_longitude', 10, 7)->nullable();
            $table->decimal('check_in_distance', 8, 2)->nullable(); // Jarak dalam meter
            $table->boolean('check_in_is_mock')->default(false);
            $table->string('check_in_status')->default('pending'); // valid, rejected, late

            // Koordinat & validasi check out
            $table->decimal('check_out_latitude', 10, 7)->nullable();
            $table->decimal('check_out_longitude', 10, 7)->nullable();
            $table->decimal('check_out_distance', 8, 2)->nullable();
            $table->boolean('check_out_is_mock')->default(false);
            $table->string('check_out_status')->nullable(); // valid, rejected

            $table->text('notes')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
        Schema::dropIfExists('offices');
        
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['participant_id']);
            $table->dropColumn(['role', 'participant_id', 'google_id', 'avatar']);
        });

        Schema::dropIfExists('si_melayur_participants');
    }
};

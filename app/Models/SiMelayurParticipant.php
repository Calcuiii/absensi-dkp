<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SiMelayurParticipant extends Model
{
    use HasFactory;

    protected $fillable = [
        'email',
        'full_name',
        'institution',
        'identification_number',
        'status',
        'start_date',
        'end_date',
        'assigned_division',
        'is_active',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'is_active' => 'boolean',
    ];

    public function user()
    {
        return $this->hasOne(User::class, 'participant_id');
    }

    /**
     * Cek apakah periode magang/PKL masih aktif hari ini
     */
    public function isWithinActivePeriod(): bool
    {
        $today = now()->toDateString();
        return ($this->start_date <= $today && $today <= $this->end_date);
    }

    /**
     * Cek apakah status diterima
     */
    public function isAccepted(): bool
    {
        return in_array(strtolower($this->status), ['accepted', 'active']);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'date',
        'check_in_at',
        'check_out_at',
        'check_in_latitude',
        'check_in_longitude',
        'check_in_distance',
        'check_in_is_mock',
        'check_in_status',
        'check_out_latitude',
        'check_out_longitude',
        'check_out_distance',
        'check_out_is_mock',
        'check_out_status',
        'notes',
        'rejection_reason',
    ];

    protected $casts = [
        'date' => 'date',
        'check_in_at' => 'datetime',
        'check_out_at' => 'datetime',
        'check_in_latitude' => 'float',
        'check_in_longitude' => 'float',
        'check_in_distance' => 'float',
        'check_in_is_mock' => 'boolean',
        'check_out_latitude' => 'float',
        'check_out_longitude' => 'float',
        'check_out_distance' => 'float',
        'check_out_is_mock' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

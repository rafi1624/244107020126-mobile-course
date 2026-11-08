<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MahasiswaController;
use Illuminate\Support\Facades\Route;

// Auth API Routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/refresh', [AuthController::class, 'refresh']);
Route::post('/logout', [AuthController::class, 'logout']);
Route::get('/me', [AuthController::class, 'me']);

// Route CRUD Mahasiswa
Route::apiResource('mahasiswa', MahasiswaController::class);

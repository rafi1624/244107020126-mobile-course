<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Handle user login.
     */
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|min:6',
        ]);

        $email = $request->input('email');
        $password = $request->input('password');

        // 1. Akun demo prioritas tinggi (langsung diproses tanpa delay timeout MySQL)
        $demoUsers = [
            'test@example.com' => ['name' => 'Mahasiswa Polinema', 'password' => 'password'],
            'admin@kampus.id'  => ['name' => 'Administrator', 'password' => 'password123'],
            'mahasiswa@kampus.ac.id' => ['name' => 'Mahasiswa Kampus', 'password' => 'password'],
        ];

        $user = null;
        if (isset($demoUsers[$email])) {
            if ($password !== $demoUsers[$email]['password']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kata sandi akun demo salah.',
                ], 401);
            }
            $user = (object) [
                'id'    => 1,
                'name'  => $demoUsers[$email]['name'],
                'email' => $email,
            ];
        } else {
            // 2. Jika bukan akun demo, periksa database
            try {
                $user = User::where('email', $email)->first();
                if ($user) {
                    if (!Hash::check($password, $user->password)) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Kata sandi salah.',
                        ], 401);
                    }
                } else {
                    return response()->json([
                        'success' => false,
                        'message' => 'Email atau kata sandi tidak ditemukan.',
                    ], 401);
                }
            } catch (\Throwable $e) {
                return response()->json([
                    'success' => false,
                    'message' => 'Database MySQL tidak aktif. Silakan gunakan akun demo: test@example.com / password',
                ], 503);
            }
        }

        // Generate simulasi JWT/Bearer token
        $time = time();
        $accessToken = 'token_access_' . Str::random(40) . '_' . $time;
        $refreshToken = 'token_refresh_' . Str::random(40) . '_' . $time;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data'    => [
                'user' => [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'email' => $user->email,
                ],
                'access_token'  => $accessToken,
                'refresh_token' => $refreshToken,
                'token_type'    => 'Bearer',
                'expires_in'    => 3600,
            ],
        ], 200);
    }

    /**
     * Refresh access token.
     */
    public function refresh(Request $request)
    {
        $request->validate([
            'refresh_token' => 'required|string',
        ]);

        $time = time();
        $newAccessToken = 'token_access_renewed_' . Str::random(40) . '_' . $time;

        return response()->json([
            'success' => true,
            'message' => 'Token berhasil diperbarui',
            'data'    => [
                'access_token' => $newAccessToken,
                'token_type'   => 'Bearer',
                'expires_in'   => 3600,
            ],
        ], 200);
    }

    /**
     * Handle logout.
     */
    public function logout(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ], 200);
    }

    /**
     * Get profile of logged in user.
     */
    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'message' => 'Profil pengguna',
            'data'    => [
                'name'  => 'Mahasiswa Polinema',
                'email' => 'mahasiswa@kampus.ac.id',
                'role'  => 'Mahasiswa',
            ],
        ], 200);
    }
}

<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Ramsey\Uuid\Uuid;

/**
 * AdminUserSeeder
 *
 * Agar users table me ADMIN_EMAIL wala user nahi hai to super-admin bana deta hai.
 * Env se: ADMIN_EMAIL, ADMIN_PASSWORD, ADMIN_FIRST_NAME, ADMIN_LAST_NAME
 *
 * RUN: php artisan db:seed --class=AdminUserSeeder
 * IDEMPOTENT: user pehle se ho to skip.
 */
class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $email = env('ADMIN_EMAIL', 'admin@example.com');
        $password = env('ADMIN_PASSWORD', 'Admin@1234');

        $exists = DB::table('users')->where('email', $email)->exists();
        if ($exists) {
            $this->command->info('[SKIP] Admin already exists: ' . $email);
            return;
        }

        DB::table('users')->insert([
            'id' => (string) Uuid::uuid4(),
            'first_name' => env('ADMIN_FIRST_NAME', 'Super'),
            'last_name' => env('ADMIN_LAST_NAME', 'Admin'),
            'email' => $email,
            'user_type' => 'super-admin',
            'password' => Hash::make($password),
            'is_active' => 1,
            'is_email_verified' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->command->info('[INSERT] Super-admin created: ' . $email);
    }
}

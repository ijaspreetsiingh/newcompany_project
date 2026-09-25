<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Ramsey\Uuid\Uuid;

/**
 * LoginSetupSeeder
 *
 * login_setups table mein default rows insert karta hai.
 * email_verification = 1  →  naye user ko register ke baad email pe OTP jayega,
 *                             verify karne ke baad hi login milega.
 *
 * RUN:
 *   php artisan db:seed --class=LoginSetupSeeder
 *
 * IDEMPOTENT: agar row pehle se hai to sirf value update hogi, duplicate nahi banega.
 */
class LoginSetupSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            // ─── Email OTP verification ON by default ──────────────────────────
            'email_verification'  => 1,

            // Phone OTP verification — SMS gateway configure hone ke baad ON karo
            // Abhi 0 rakha hai taaki SMS gateway na hone par registration fail na ho
            'phone_verification'  => 0,

            // Login options — manual (email+password) ON, OTP login OFF by default
            // Admin panel se baad mein change kar sakte hain
            'login_options'       => json_encode([
                'manual_login'       => 1,
                'otp_login'          => 0,
                'social_media_login' => 1,
            ]),

            // Social media login options — Google ON, Facebook ON, Apple OFF
            'social_media_login_options' => json_encode([
                'google'   => 1,
                'facebook' => 1,
                'apple'    => 0,
            ]),
        ];

        foreach ($defaults as $key => $value) {
            $exists = DB::table('login_setups')->where('key', $key)->exists();

            if ($exists) {
                // Sirf email_verification ki value force-update karo
                // Baaki rows admin ne change ki ho sakti hain, unhe chhedo mat
                if ($key === 'email_verification') {
                    DB::table('login_setups')
                        ->where('key', $key)
                        ->update(['value' => $value, 'updated_at' => now()]);

                    $this->command->info("  [UPDATE] login_setups.{$key} = {$value}");
                } else {
                    $this->command->line("  [SKIP]   login_setups.{$key} already exists");
                }
            } else {
                DB::table('login_setups')->insert([
                    'id'         => Uuid::uuid4()->toString(),
                    'key'        => $key,
                    'value'      => is_array($value) ? json_encode($value) : $value,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                $this->command->info("  [INSERT] login_setups.{$key} = {$value}");
            }
        }

        $this->command->info('');
        $this->command->info('✅  Email OTP verification is now ENABLED by default.');
        $this->command->info('   New users must verify their email before they can login.');
    }
}

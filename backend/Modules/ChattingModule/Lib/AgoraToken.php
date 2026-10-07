<?php

namespace Modules\ChattingModule\Lib;

/**
 * Agora legacy AccessToken (version "006") builder — pure PHP port of the
 * official reference implementation:
 * https://github.com/AgoraIO/Tools/blob/master/DynamicKey/AgoraDynamicKey/php/src/AccessToken.php
 *
 * Koi composer dependency nahi chahiye; App Certificate server par hi rehta hai
 * (token client ko milta hai, certificate kabhi nahi).
 */
class AgoraToken
{
    private const PRIVILEGE_JOIN_CHANNEL = 1;
    private const PRIVILEGE_PUBLISH_AUDIO = 2;
    private const PRIVILEGE_PUBLISH_VIDEO = 3;

    /**
     * Build a signed RTC token for joining $channelName as $uid.
     *
     * @param string $appId          Agora project App ID (40 hex chars)
     * @param string $appCertificate Agora project App Certificate
     * @param string $channelName    RTC channel (hamara call id)
     * @param string $uid            Numeric uid (string representation)
     * @param int    $expireSeconds  Token lifetime in seconds (default 1h)
     * @return string Token006 string
     */
    public static function build(string $appId, string $appCertificate, string $channelName, string $uid, int $expireSeconds = 3600): string
    {
        $salt = random_int(0, 100000);
        $ts = time() + 24 * 3600;
        $privilegeTs = time() + $expireSeconds;

        $privileges = [
            self::PRIVILEGE_JOIN_CHANNEL => $privilegeTs,
            self::PRIVILEGE_PUBLISH_AUDIO => $privilegeTs,
            self::PRIVILEGE_PUBLISH_VIDEO => $privilegeTs,
        ];

        // message = salt(4 LE) + ts(4 LE) + count(2 LE) + [key(2 LE) + value(4 LE)]*
        $msg = pack('V', $salt) . pack('V', $ts) . pack('v', count($privileges));
        foreach ($privileges as $key => $value) {
            $msg .= pack('v', $key) . pack('V', $value);
        }

        $signature = hash_hmac('sha256', $appId . $channelName . $uid . $msg, $appCertificate, true);

        $content = pack('v', strlen($signature)) . $signature
            . pack('V', crc32($channelName) & 0xffffffff)
            . pack('V', crc32($uid) & 0xffffffff)
            . pack('v', strlen($msg)) . $msg;

        return '006' . $appId . base64_encode($content);
    }

    /**
     * User uuid se stable numeric RTC uid (4294967295 max).
     * Dono parties ke uid alag honge kyunki uuid alag hain.
     */
    public static function uidFromUserId(string $userId): string
    {
        return (string)sprintf('%u', crc32($userId));
    }
}

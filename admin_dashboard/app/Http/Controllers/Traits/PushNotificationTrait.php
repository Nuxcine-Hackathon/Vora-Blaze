<?php

namespace App\Http\Controllers\Traits;

use App\Models\GeneralSetting;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

trait PushNotificationTrait
{
    /**
     * Send a push notification to a single device via FCM.
     *
     * @param  string  $deviceToken
     * @param  string  $title
     * @param  string  $body
     * @param  array  $data  Optional data payload
     * @return void
     */
    public function sendFcmMessage($deviceToken, $subject, $message, $data = [], $vendorNotification = 0, $userType = null)
    {
        $payloadData = $this->parseBookingData($data);
        $payloadData['vendorNotification'] = $vendorNotification;

        $settings = GeneralSetting::whereIn('meta_key', [
            'push_notification_status',
            'onesignal_app_id',
            'onesignal_rest_api_key',
            'onesignal_app_id_driver',
            'onesignal_rest_api_key_driver',
        ])->get()->pluck('meta_value', 'meta_key')->toArray();

        if ($settings['push_notification_status'] == 'onesignal') {
            if ($userType === 'driver') {
                $appId = $settings['onesignal_app_id_driver'];
                $restApiKey = $settings['onesignal_rest_api_key_driver'];
            } else {
                $appId = $settings['onesignal_app_id'];
                $restApiKey = $settings['onesignal_rest_api_key'];
            }

            $payload = [
                'app_id' => $appId,
                'include_player_ids' => [$deviceToken],
                'contents' => ['en' => $message],
                'headings' => ['en' => $subject],
                'data' => $payloadData,
            ];

            $payloadJson = json_encode($payload);

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'https://onesignal.com/api/v1/notifications');
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'Authorization: Basic '.$restApiKey,
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $payloadJson);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            // Log notification attempt
            Log::info('FCM/OneSignal Notification Attempt', [
                'deviceToken' => $deviceToken,
                'subject' => $subject,
                'message' => $message,
                'payload' => $payloadData,
                'response' => $response,
                'httpCode' => $httpCode,
            ]);

            if ($httpCode === 200) {
                return response()->json(['success' => true, 'message' => 'Notification sent to user!']);
            } else {
                return response()->json(['success' => false, 'message' => 'Failed to send notification', 'error' => $response]);
            }
        }
    }

    /**
     * Send a push notification to multiple devices via FCM.
     *
     * @param  string  $title
     * @param  string  $body
     * @param  array  $data  Optional data payload
     * @return void
     */
    public function sendPushNotificationsToDevices(array $deviceTokens, $title, $body, $data = [])
    {
        $url = 'https://fcm.googleapis.com/fcm/send';
        $serverKey = env('FCM_SERVER_KEY');

        $payload = [
            'registration_ids' => $deviceTokens,
            'notification' => [
                'title' => $title,
                'body' => $body,
            ],
            'data' => $data,
        ];

        $headers = [
            'Authorization' => 'key='.$serverKey,
            'Content-Type' => 'application/json',
        ];

        $response = Http::withHeaders($headers)->post($url, $payload);

        if ($response->failed()) {
            Log::error('Failed to send push notifications', ['response' => $response->body()]);
        }
    }

    /**
     * Send a push notification to all devices subscribed to a particular topic via FCM.
     *
     * @param  string  $topic
     * @param  string  $title
     * @param  string  $body
     * @param  array  $data  Optional data payload
     * @return void
     */
    public function sendPushNotificationToTopic($topic, $title, $body, $data = [])
    {
        $url = 'https://fcm.googleapis.com/fcm/send';
        $serverKey = env('FCM_SERVER_KEY');

        $payload = [
            'to' => '/topics/'.$topic,
            'notification' => [
                'title' => $title,
                'body' => $body,
            ],
            'data' => $data,
        ];

        $headers = [
            'Authorization' => 'key='.$serverKey,
            'Content-Type' => 'application/json',
        ];

        $response = Http::withHeaders($headers)->post($url, $payload);

        if ($response->failed()) {
            Log::error('Failed to send push notification to topic', ['response' => $response->body()]);
        }
    }

    private function parseBookingData($data)
    {

        $checkIn = $this->extractValue($data, 'check_in');

        if ($checkIn !== null) {
            $bookingStatus = $this->extractValue($data, 'status') ?? 'Unknown';

            return [
                'status' => $bookingStatus,
                'route' => 'booking',
            ];
        }
        $guestRating = $this->extractValue($data, 'guest_rating');
        $hostRating = $this->extractValue($data, 'host_rating');

        // If either guest_rating or host_rating exists, set route to 'review'
        if ($guestRating !== null || $hostRating !== null) {
            return [
                'route' => 'review',
            ];
        }

        return [

            'route' => 'none',
        ];
    }

    private function extractValue($data, $key)
    {

        if (is_array($data) || is_object($data)) {

            if (isset($data[$key])) {
                return $data[$key];
            }

            foreach ($data as $item) {
                $result = $this->extractValue($item, $key);
                if ($result !== null) {
                    return $result;
                }
            }
        }

        return null;
    }
}

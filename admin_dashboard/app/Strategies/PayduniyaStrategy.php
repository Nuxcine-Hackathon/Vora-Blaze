<?php

namespace App\Strategies;

use App\Http\Controllers\Traits\PaymentStatusUpdaterTrait;
use App\Models\GeneralSetting;

class PayduniyaStrategy implements PaymentStrategy
{
    use PaymentStatusUpdaterTrait;

    /**
     * When no PayDunya credentials are configured (config('services.paydunya.mode') === 'demo',
     * the default), the strategy simulates a successful Mobile Money confirmation instead of
     * calling PayDunya's API. This keeps the payment flow demoable without live merchant keys.
     */
    private function isDemoMode(): bool
    {
        return config('services.paydunya.mode') !== 'live' && config('services.paydunya.mode') !== 'sandbox'
            || empty(config('services.paydunya.private_key'));
    }

    private function headers(): array
    {
        return [
            'Content-Type: application/json',
            'PAYDUNYA-MASTER-KEY: '.config('services.paydunya.master_key'),
            'PAYDUNYA-PRIVATE-KEY: '.config('services.paydunya.private_key'),
            'PAYDUNYA-TOKEN: '.config('services.paydunya.token'),
        ];
    }

    private function baseUrl(): string
    {
        return config('services.paydunya.mode') === 'live'
            ? 'https://app.paydunya.com/api/v1'
            : 'https://app.paydunya.com/sandbox-api/v1';
    }

    public function process($bookingId, $bookingData, $request)
    {
        if ($this->isDemoMode()) {
            return redirect()->route('handleReturn', ['booking' => $bookingId, 'method' => 'payduniya']);
        }

        $siteName = GeneralSetting::where('meta_key', 'general_name')->value('meta_value');

        $postData = [
            'invoice' => [
                'items' => [
                    'item_0' => ['name' => $bookingData->prop_title],
                ],
                'total_amount' => $bookingData->amount_to_pay,
                'description' => '',
            ],
            'store' => [
                'name' => $siteName ?: config('app.name'),
            ],
            'custom_data' => ['orderID' => $bookingId],
            'actions' => [
                'cancel_url' => route('handleCancel', ['booking' => $bookingId, 'method' => 'payduniya']),
                'return_url' => route('handleReturn', ['booking' => $bookingId, 'method' => 'payduniya']),
                'callback_url' => route('handleCallback', ['booking' => $bookingId, 'method' => 'payduniya']),
            ],
        ];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->baseUrl().'/checkout-invoice/create');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($postData));
        curl_setopt($ch, CURLOPT_HTTPHEADER, $this->headers());
        $response = json_decode(curl_exec($ch), true);
        curl_close($ch);

        if (isset($response['response_code']) && $response['response_code'] === '00') {
            return redirect($response['response_text'])->with('success', 'Please make payment');
        }

        return redirect('/invalid-order')->with('error', 'Invalid booking ID');
    }

    public function cancel($bookingId, $bookingData)
    {
        return '/payment_methods?booking='.$bookingId;
    }

    public function refund($bookingId, $bookingData)
    {
        // Refund via PayDunya's disburse API — not implemented in demo mode.
    }

    public function return($bookingId, $requestData)
    {
        if ($this->isDemoMode()) {
            $saveStatus = json_decode($this->updateBookingStatus($bookingId, (object) [
                'response_data' => json_encode(['mode' => 'demo']),
                'gateway_name' => 'paydunya',
                'payment_status' => 'completed',
                'transaction_id' => 'DEMO-'.$bookingId.'-'.time(),
            ]), true);

            return $saveStatus['status'] === 'success' ? '/payment_success' : '/payment_fail';
        }

        $invoiceId = $_GET['token'] ?? null;
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->baseUrl().'/checkout-invoice/confirm/'.$invoiceId);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $this->headers());
        $responseData = json_decode(curl_exec($ch), true);
        curl_close($ch);

        if (($responseData['response_code'] ?? null) == '00' && ($responseData['status'] ?? null) == 'completed') {
            $saveStatus = json_decode($this->updateBookingStatus($responseData['custom_data']['orderID'], (object) [
                'response_data' => json_encode($responseData),
                'gateway_name' => 'paydunya',
                'payment_status' => $responseData['status'],
                'transaction_id' => $responseData['invoice']['token'],
            ]), true);

            return $saveStatus['status'] === 'success' ? '/payment_success' : '/payment_fail';
        }

        return '/payment_fail';
    }

    public function callback($bookingId, $requestData)
    {
        if ($this->isDemoMode()) {
            return;
        }

        $masterKey = config('services.paydunya.master_key');
        if (($_POST['data']['hash'] ?? null) !== hash('sha512', $masterKey)) {
            abort(403, 'This request was not issued by PayDunya');
        }

        if (($_POST['data']['status'] ?? null) === 'completed') {
            // Booking status is confirmed via return()/webhook payload processing above.
        }
    }
}

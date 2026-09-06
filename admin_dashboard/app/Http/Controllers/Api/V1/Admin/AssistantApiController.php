<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;
use Illuminate\Http\Request;

class AssistantApiController extends Controller
{
    /**
     * Resolve a CA bundle for Guzzle's SSL verification. PHP's built-in
     * dev server (the "cli-server" SAPI used by `artisan serve`) has been
     * observed to report an empty curl.cainfo/openssl.cafile even when
     * php.ini sets one correctly for the "cli" SAPI on the same machine —
     * so a bundled, project-relative certificate is used instead of
     * depending on machine-specific php.ini configuration, which also
     * would not travel with the repository to another environment.
     */
    private function caBundlePath(): string|bool
    {
        $bundled = storage_path('certs/cacert.pem');
        if (file_exists($bundled)) {
            return $bundled;
        }

        $iniPath = ini_get('curl.cainfo') ?: ini_get('openssl.cafile');

        return $iniPath && file_exists($iniPath) ? $iniPath : true;
    }

    /**
     * System context grounding the assistant in OnTravel's actual product
     * (Cameroon ride-hailing: car/moto, FCFA pricing, Mobile Money, SOS).
     * Kept short and factual — the assistant should not invent prices,
     * ETAs, or policies it isn't given.
     */
    private const SYSTEM_CONTEXT = <<<'TXT'
Tu es l'assistant OnTravel, une application de mobilité (voiture et moto-taxi)
au Cameroun (Douala, Yaoundé). Réponds en français par défaut (en anglais si
l'utilisateur écrit en anglais), en 2-3 phrases maximum, ton simple et direct.

Tu peux aider avec : comment réserver une course, la différence entre les
options voiture et moto, le paiement par Mobile Money (MTN/Orange Money),
le bouton SOS et le partage de trajet, l'annulation d'une course, et des
questions générales sur l'application.

Tu ne connais pas le prix exact ni la position en temps réel d'une course en
cours : si on te le demande, invite poliment à consulter l'écran de
réservation ou de suivi dans l'application plutôt que d'inventer un chiffre.
TXT;

    public function chat(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:1000',
            'history' => 'nullable|array',
            'history.*.role' => 'required_with:history|in:user,model',
            'history.*.text' => 'required_with:history|string',
        ]);

        $apiKey = config('services.gemini.key');
        if (empty($apiKey)) {
            return response()->json([
                'status' => 500,
                'message' => 'Assistant is not configured.',
            ], 500);
        }

        $contents = [
            ['role' => 'user', 'parts' => [['text' => self::SYSTEM_CONTEXT]]],
            ['role' => 'model', 'parts' => [['text' => "D'accord, je suis prêt à aider les utilisateurs d'OnTravel."]]],
        ];

        foreach ($request->input('history', []) as $turn) {
            $contents[] = [
                'role' => $turn['role'],
                'parts' => [['text' => $turn['text']]],
            ];
        }

        $contents[] = ['role' => 'user', 'parts' => [['text' => $request->input('message')]]];

        $model = config('services.gemini.model', 'gemini-3.5-flash-lite');
        $client = new Client;

        try {
            $response = $client->post(
                "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent",
                [
                    'headers' => [
                        'x-goog-api-key' => $apiKey,
                        'Content-Type' => 'application/json',
                    ],
                    'json' => [
                        'contents' => $contents,
                        'generationConfig' => [
                            'temperature' => 0.4,
                            'maxOutputTokens' => 300,
                        ],
                    ],
                    'timeout' => 20,
                    'verify' => $this->caBundlePath(),
                ]
            );

            $data = json_decode($response->getBody()->getContents(), true);
            $reply = $data['candidates'][0]['content']['parts'][0]['text'] ?? null;

            if (! $reply) {
                return response()->json([
                    'status' => 502,
                    'message' => 'Assistant did not return a response.',
                ], 502);
            }

            return response()->json([
                'status' => 200,
                'message' => 'success',
                'data' => ['reply' => trim($reply)],
            ]);
        } catch (GuzzleException $e) {
            \Log::error('Gemini assistant error: '.$e->getMessage());

            return response()->json([
                'status' => 502,
                'message' => 'Assistant is temporarily unavailable.',
                'debug' => config('app.debug') ? $e->getMessage() : null,
            ], 502);
        }
    }
}

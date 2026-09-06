const supabase = require('../config/supabase');

// --- Mode "mock" : matching par mots-clés (identique au principe du notebook Franck) ---
// Reprend les intentions du prototype nuxcine_ride_assistant_ia_complet.ipynb.
const INTENTS = [
  { intent: 'driver_location', keywords: ['où est mon chauffeur', 'ou est mon chauffeur', 'position chauffeur'] },
  { intent: 'driver_info', keywords: ['qui est mon chauffeur', 'quel chauffeur'] },
  { intent: 'vehicle_info', keywords: ['quelle voiture', 'quel véhicule', 'quel vehicule'] },
  { intent: 'trip_eta', keywords: ['combien de temps', 'temps restant', 'eta'] },
  { intent: 'trip_distance', keywords: ['combien de kilomètres', 'combien de km', 'distance restante'] },
  { intent: 'route_info', keywords: ['itinéraire', 'itineraire', 'trajet'] },
  { intent: 'route_deviation', keywords: ['déviation', 'deviation', 'écart'] },
  { intent: 'price_explanation', keywords: ['pourquoi ce prix', 'pourquoi ma course coûte', 'explication prix'] },
  { intent: 'price_locked', keywords: ['le prix va changer', 'prix verrouillé', 'prix bloqué'] },
  { intent: 'estimate_price', keywords: ['combien ça coûte', 'combien coute', 'prix estimé'] },
  { intent: 'cancel_trip', keywords: ['annuler', 'comment annuler'] },
  { intent: 'payment_problem', keywords: ['payer', 'mobile money', 'paiement'] },
  { intent: 'safety_emergency', keywords: ['sos', 'urgence', 'danger', 'aide immédiate'] },
  { intent: 'app_help', keywords: ["comment utiliser", "comment ça marche", 'aide'] },
];

function detectIntent(message) {
  const lower = message.toLowerCase();
  const match = INTENTS.find((i) => i.keywords.some((k) => lower.includes(k)));
  return match ? match.intent : 'unknown';
}

async function buildFactualContext(tripId) {
  if (!tripId) return null;
  const { data: trip } = await supabase.from('trips').select('*').eq('id', tripId).maybeSingle();
  if (!trip) return null;

  let driver = null;
  if (trip.driver_id) {
    const { data } = await supabase.from('users').select('nom, prenom').eq('id', trip.driver_id).maybeSingle();
    driver = data;
  }
  return { trip, driver };
}

function mockResponse(intent, context) {
  const trip = context?.trip;
  switch (intent) {
    case 'driver_location':
      return trip?.driver_id ? `Votre chauffeur est en route. Statut actuel : ${trip.status}.` : "Aucun chauffeur n'est encore assigné à votre course.";
    case 'driver_info':
      return context?.driver ? `Votre chauffeur est ${context.driver.prenom} ${context.driver.nom}.` : "Aucun chauffeur assigné pour le moment.";
    case 'trip_eta':
      return trip?.duration_min ? `Durée estimée restante : environ ${trip.duration_min} minutes.` : "Je n'ai pas encore cette information.";
    case 'trip_distance':
      return trip?.distance_km ? `Distance du trajet : ${trip.distance_km} km.` : "Je n'ai pas encore cette information.";
    case 'price_explanation':
      return trip?.locked_price ? `Le prix de ${trip.locked_price} FCFA inclut le tarif de base, la distance et la durée estimée.` : "Aucun prix n'est encore calculé.";
    case 'price_locked':
      return trip?.locked_price ? 'Votre prix est verrouillé et ne changera plus, même en cas de trafic ou de déviation.' : "Le prix n'est pas encore verrouillé.";
    case 'cancel_trip':
      return "Vous pouvez annuler votre course depuis l'écran de suivi. Des frais peuvent s'appliquer selon le délai.";
    case 'payment_problem':
      return 'Vous pouvez payer en espèces, Mobile Money ou carte selon la configuration de votre compte.';
    case 'safety_emergency':
      return "Alerte prise en compte. Utilisez le bouton SOS pour prévenir immédiatement l'assistance.";
    case 'app_help':
      return "Je peux vous aider à commander une course, suivre votre chauffeur, ou répondre à vos questions sur le prix et le paiement.";
    default:
      return "Je n'ai pas bien compris votre demande. Pouvez-vous reformuler ?";
  }
}

// POST /assistant — { user_id (via token), trip_id, message }
// Architecture : message -> détection intention -> lecture DB -> réponse factuelle
// (jamais de réponse inventée par un LLM, cf. Assistant_IA_Docs.docx §6)
async function askAssistant(req, res, next) {
  try {
    const userId = req.user?.id || req.body.user_id;
    const { trip_id, message } = req.body;

    const intent = detectIntent(message);
    const context = await buildFactualContext(trip_id);

    let response;
    if (intent === 'safety_emergency') {
      // Escalade automatique vers les alertes (I4 côté Franck)
      await supabase.from('alerts').insert([{ trip_id: trip_id || null, user_id: userId, type: 'sos', details: `Déclenché via assistant : "${message}"` }]);
      response = mockResponse(intent, context);
    } else if (process.env.ASSISTANT_MODE === 'llm' && process.env.ASSISTANT_API_URL) {
      // Point de branchement pour Franck : appel à un vrai service IA (I3, optionnel)
      // response = await callExternalAssistant({ message, context });
      response = mockResponse(intent, context); // fallback tant que non branché
    } else {
      response = mockResponse(intent, context);
    }

    await supabase.from('assistant_logs').insert([{ user_id: userId, trip_id: trip_id || null, message, detected_intent: intent, response }]);

    res.json({ intent, response });
  } catch (err) {
    next(err);
  }
}

module.exports = { askAssistant, detectIntent };

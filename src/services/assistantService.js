/**
 * assistantService.js
 *
 * Port JS fidèle de la classe `IntegratedRideAssistant` du notebook
 * nuxcine_backend_integration_complete.ipynb.
 *
 * ADAPTÉ AU SCHÉMA RÉEL du backend vora-backend (pas le schéma recalibré
 * générique) :
 *   - table "trips" (pas "course")
 *   - colonne "status" (pas "trip_status"), valeurs :
 *     recherche_chauffeur / acceptee / en_cours / terminee /
 *     annulee_client / annulee_chauffeur
 *   - colonne "duration_min" (pas "estimated_duration_min")
 *   - PAS de colonne route_deviation_alert sur trips : une déviation est
 *     un enregistrement dans la table "alerts" (type = 'deviation'),
 *     posé par POST /trips/:id/check-deviation.
 *
 * Utilisation dans assistantController.js :
 *
 *   const { respond } = require("../services/assistantService");
 *   async function askAssistant(req, res, next) {
 *     const { trip_id, message } = req.body;
 *     const result = await respond({ supabase, user_id: req.user.id, trip_id, message });
 *     res.json(result);
 *   }
 */

const { randomUUID } = require("crypto");

const ACCENT_MAP = {
  é: "e", è: "e", ê: "e", ë: "e",
  à: "a", â: "a", ù: "u", û: "u",
  î: "i", ï: "i", ô: "o", ç: "c",
};

function normalize(text) {
  let t = String(text ?? "").toLowerCase().trim();
  for (const [a, b] of Object.entries(ACCENT_MAP)) {
    t = t.split(a).join(b);
  }
  return t;
}

function containsAny(text, keywords) {
  return keywords.some((k) => text.includes(k));
}

/**
 * Détection d'intention — ordre de priorité identique au notebook.
 */
function detectIntent(message) {
  const m = normalize(message);

  if (containsAny(m, ["sos", "danger", "urgence", "agression"])) {
    return "safety_emergency";
  }
  if (containsAny(m, ["prix va changer", "prix fixe", "prix verrouille", "prix bloque"])) {
    return "price_locked";
  }
  if (containsAny(m, ["pourquoi ce prix", "pourquoi le prix", "prix de la course", "combien coute", "tarif"])) {
    return "price_explanation";
  }
  if (containsAny(m, ["deviation", "ecart", "pas le bon chemin"])) {
    return "route_deviation";
  }
  if (containsAny(m, ["itineraire", "route", "trajet", "chemin"])) {
    return "route_info";
  }
  if (containsAny(m, ["statut", "ou en est", "course commencee", "course terminee"])) {
    return "trip_status";
  }
  if (containsAny(m, ["annuler", "annulation"])) {
    return "cancel_trip";
  }
  if (containsAny(m, ["paiement", "payer", "momo", "mobile money", "orange money", "especes"])) {
    return "payment_help";
  }
  if (containsAny(m, ["chauffeur", "conducteur"])) {
    return "driver_info";
  }
  if (containsAny(m, ["application", "comment utiliser", "aide"])) {
    return "app_help";
  }
  return "unknown";
}

function formatFcfa(n) {
  return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

const STATUS_LABELS = {
  recherche_chauffeur: "en recherche de chauffeur",
  acceptee: "acceptée par un chauffeur",
  en_cours: "en cours",
  terminee: "terminée",
  annulee_client: "annulée (par le client)",
  annulee_chauffeur: "annulée (par le chauffeur)",
};

/**
 * Construit la réponse texte + le flag d'escalade à partir de l'intention,
 * de la ligne "trips" et (si pertinent) de la dernière alerte de déviation.
 *
 * @param {string} intent
 * @param {Object} trip - ligne de la table "trips"
 * @param {Object|null} lastDeviationAlert - dernière ligne "alerts" type=deviation, ou null
 */
function buildResponse(intent, trip, lastDeviationAlert) {
  let response;
  let escalation = 0;

  switch (intent) {
    case "price_explanation":
      response =
        `Le prix estimé est de ${formatFcfa(trip.estimated_price)} FCFA. ` +
        `Il tient notamment compte de la distance (${Number(trip.distance_km).toFixed(2)} km), ` +
        `de la durée estimée (${Math.round(trip.duration_min)} min) ` +
        `et de la catégorie ${trip.vehicle_category}.`;
      break;

    case "price_locked":
      if (trip.locked_price === null || trip.locked_price === undefined) {
        response =
          `Le prix actuel est une estimation de ${formatFcfa(trip.estimated_price)} FCFA. ` +
          `Il sera verrouillé lorsque vous confirmerez la course.`;
      } else {
        response =
          `Le prix confirmé est de ${formatFcfa(trip.locked_price)} FCFA. ` +
          `Il reste verrouillé pendant la course, même si le trafic ou l'itinéraire évolue.`;
      }
      break;

    case "route_info":
      response =
        `Le trajet prévu va de ${trip.pickup_zone ?? trip.pickup_landmark} ` +
        `à ${trip.destination_zone}, sur environ ` +
        `${Number(trip.distance_km).toFixed(2)} km et ${Math.round(trip.duration_min)} minutes.`;
      break;

    case "route_deviation":
      if (lastDeviationAlert) {
        response =
          `Une déviation par rapport à l'itinéraire prévu a été signalée ` +
          `(${Number(lastDeviationAlert.distance_km ?? 0).toFixed(2)} km d'écart). ` +
          `Le prix verrouillé n'est pas modifié.`;
        escalation = 1;
      } else {
        response = "Aucune déviation significative n'est signalée pour cette course.";
      }
      break;

    case "trip_status":
      response = `Le statut actuel de votre course est : ${STATUS_LABELS[trip.status] ?? trip.status}.`;
      break;

    case "driver_info":
      if (!trip.driver_id) {
        response = "Aucun chauffeur n'est encore affecté à cette course.";
      } else {
        response =
          `Le chauffeur affecté à cette course porte l'identifiant ${trip.driver_id}. ` +
          `Les informations détaillées peuvent être récupérées depuis la table Chauffeur.`;
      }
      break;

    case "cancel_trip":
      if (["terminee", "annulee_client", "annulee_chauffeur"].includes(trip.status)) {
        response = "Cette course ne peut plus être annulée depuis son état actuel.";
      } else {
        response =
          "Vous pouvez demander l'annulation depuis l'écran de la course. " +
          "Une confirmation doit être demandée avant de finaliser l'annulation.";
      }
      break;

    case "payment_help":
      response = "Le MVP prévoit les paiements en espèces, Mobile Money et carte simulée.";
      break;

    case "safety_emergency":
      response =
        "Utilisez immédiatement le bouton SOS de l'application. La course et la dernière " +
        "position disponible doivent être transmises au module de sécurité.";
      escalation = 1;
      break;

    case "app_help":
      response =
        "Je peux vous renseigner sur le prix, la course, l'itinéraire, le chauffeur, " +
        "le paiement, l'annulation et les fonctions de sécurité.";
      break;

    default:
      response =
        "Je n'ai pas identifié précisément votre demande. Essayez par exemple : " +
        "« Pourquoi ce prix ? », « Le prix va-t-il changer ? » ou « Quel est mon itinéraire ? ».";
  }

  return { response, escalation };
}

/**
 * Point d'entrée principal, appelé depuis la route POST /assistant.
 *
 * @param {Object} args
 * @param {import('@supabase/supabase-js').SupabaseClient} args.supabase
 * @param {string} args.user_id
 * @param {string} args.trip_id
 * @param {string} args.message
 * @param {string} [args.tripTable="course"] - nom de la table courses dans Supabase
 * @param {string} [args.logTable="assistant_conversation"] - nom de la table de logs
 */
async function respond({
  supabase,
  user_id,
  trip_id,
  message,
  tripTable = "trips",
  alertsTable = "alerts",
  logTable = "assistant_conversation",
}) {
  const { data: trip, error } = await supabase
    .from(tripTable)
    .select("*")
    .eq("id", trip_id)
    .maybeSingle();

  let intent, response, escalation;
  intent = detectIntent(message);

  if (error || !trip) {
    response = "Je ne trouve pas cette course.";
    escalation = 1;
  } else {
    let lastDeviationAlert = null;
    if (intent === "route_deviation") {
      const { data: alertRow } = await supabase
        .from(alertsTable)
        .select("*")
        .eq("trip_id", trip_id)
        .eq("type", "deviation")
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      lastDeviationAlert = alertRow || null;
    }
    ({ response, escalation } = buildResponse(intent, trip, lastDeviationAlert));
  }

  const log = {
    conversation_id: "CONV_" + randomUUID().replace(/-/g, "").slice(0, 10).toUpperCase(),
    user_id: String(user_id),
    trip_id: String(trip_id),
    user_message: String(message),
    detected_intent: intent,
    response_text: response,
    escalation_required: escalation,
    message_timestamp: new Date().toISOString(),
  };

  // Log best-effort : si la table n'existe pas encore ou si l'insert échoue,
  // on ne bloque jamais la réponse à l'utilisateur pour autant.
  try {
    await supabase.from(logTable).insert(log);
  } catch (_) {
    /* non bloquant */
  }

  return log;
}

module.exports = { detectIntent, buildResponse, respond, normalize };

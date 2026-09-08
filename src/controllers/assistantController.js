const supabase = require('../config/supabase');
const { respond } = require('../services/assistantService');

// POST /assistant — body: { trip_id, message }
// Remplace le mode ASSISTANT_MODE=mock générique par la logique métier
// portée du notebook nuxcine_backend_integration_complete.ipynb (Franck) :
// détection d'intention par mots-clés + réponse construite à partir des
// données réelles de la course (jamais inventée par un LLM).
async function askAssistant(req, res, next) {
  try {
    const { trip_id, message } = req.body;
    const user_id = req.user.id;

    const result = await respond({ supabase, user_id, trip_id, message });

    res.json({
      response: result.response_text,
      detected_intent: result.detected_intent,
      escalation_required: !!result.escalation_required,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { askAssistant };

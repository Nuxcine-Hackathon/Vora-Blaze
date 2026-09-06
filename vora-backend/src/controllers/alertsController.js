const supabase = require('../config/supabase');

// POST /alerts/sos — bouton d'urgence passager ou chauffeur
async function triggerSos(req, res, next) {
  try {
    const userId = req.user.id;
    const { trip_id, lat, lng, details } = req.body;

    const { data, error } = await supabase
      .from('alerts')
      .insert([{ trip_id: trip_id || null, user_id: userId, type: 'sos', lat, lng, details }])
      .select()
      .single();

    if (error) throw error;

    // Ici, en V2 : notifier support / contacts d'urgence en temps réel (websocket, SMS...)
    res.status(201).json({ message: 'Alerte SOS enregistrée.', alert: data });
  } catch (err) {
    next(err);
  }
}

// GET /alerts — liste des alertes (support/admin)
async function listAlerts(req, res, next) {
  try {
    const { data, error } = await supabase.from('alerts').select('*').order('created_at', { ascending: false });
    if (error) throw error;
    res.json({ alerts: data });
  } catch (err) {
    next(err);
  }
}

// PATCH /alerts/:id/resolve
async function resolveAlert(req, res, next) {
  try {
    const { data, error } = await supabase.from('alerts').update({ resolved: true }).eq('id', req.params.id).select().single();
    if (error || !data) return res.status(404).json({ error: 'Alerte introuvable.' });
    res.json({ alert: data });
  } catch (err) {
    next(err);
  }
}

module.exports = { triggerSos, listAlerts, resolveAlert };

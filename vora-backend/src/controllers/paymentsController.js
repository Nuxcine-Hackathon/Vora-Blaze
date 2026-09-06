const supabase = require('../config/supabase');

// POST /payments — simule un paiement pour une course terminée
async function createPayment(req, res, next) {
  try {
    const { trip_id, method = 'especes' } = req.body;

    const { data: trip, error: tripErr } = await supabase.from('trips').select('locked_price, status').eq('id', trip_id).single();
    if (tripErr || !trip) return res.status(404).json({ error: 'Course introuvable.' });
    if (trip.status !== 'terminee') return res.status(400).json({ error: 'La course doit être terminée avant paiement.' });

    // Simulation : succès à 95% (pour tester aussi le cas d'échec côté frontend)
    const success = Math.random() > 0.05;

    const { data, error } = await supabase
      .from('payments')
      .insert([{
        trip_id,
        amount: trip.locked_price,
        method,
        status: success ? 'confirme' : 'echoue',
        simulated: true,
      }])
      .select()
      .single();

    if (error) throw error;

    if (success) {
      await supabase.from('trips').update({ status: 'terminee' }).eq('id', trip_id);
    }

    res.status(success ? 201 : 402).json({ payment: data });
  } catch (err) {
    next(err);
  }
}

// GET /payments/:tripId
async function getPaymentByTrip(req, res, next) {
  try {
    const { data, error } = await supabase.from('payments').select('*').eq('trip_id', req.params.tripId).maybeSingle();
    if (error) throw error;
    if (!data) return res.status(404).json({ error: 'Aucun paiement trouvé pour cette course.' });
    res.json({ payment: data });
  } catch (err) {
    next(err);
  }
}

module.exports = { createPayment, getPaymentByTrip };

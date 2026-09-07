const supabase = require('../config/supabase');
const { calculatePrice } = require('../utils/pricing');

// POST /trips/estimate — ne touche pas la base, juste un calcul (locked_price reste NULL)
async function estimate(req, res, next) {
  try {
    const { distance_km, vehicle_category = 'eco', traffic_level = 'normal' } = req.body;

    const { price, durationMin } = calculatePrice({
      distanceKm: Number(distance_km),
      category: vehicle_category,
      trafficLevel: traffic_level,
    });

    res.json({
      estimated_price: price,
      locked_price: null,
      duration_min: durationMin,
      vehicle_category,
    });
  } catch (err) {
    next(err);
  }
}

// POST /trips — création de la course avec locked_price figé (le client vient de confirmer)
async function createTrip(req, res, next) {
  try {
    const clientId = req.user.id;
    const {
      pickup_zone, pickup_lat, pickup_lng, pickup_landmark,
      destination_zone, destination_lat, destination_lng,
      vehicle_category = 'eco', distance_km, traffic_level = 'normal',
    } = req.body;

    const { price, durationMin } = calculatePrice({
      distanceKm: Number(distance_km),
      category: vehicle_category,
      trafficLevel: traffic_level,
    });

    const { data, error } = await supabase
      .from('trips')
      .insert([{
        client_id: clientId,
        pickup_zone, pickup_lat, pickup_lng, pickup_landmark,
        destination_zone, destination_lat, destination_lng,
        vehicle_category, distance_km,
        duration_min: durationMin,
        estimated_price: price,
        locked_price: price, // verrouillé dès la confirmation, ne bougera plus (cf. cahier des charges §4)
        status: 'recherche_chauffeur',
      }])
      .select()
      .single();

    if (error) throw error;

    res.status(201).json({ trip: data });
  } catch (err) {
    next(err);
  }
}

// GET /trips/:id
async function getTrip(req, res, next) {
  try {
    const { data, error } = await supabase.from('trips').select('*').eq('id', req.params.id).single();
    if (error) return res.status(404).json({ error: 'Course introuvable.' });
    res.json({ trip: data });
  } catch (err) {
    next(err);
  }
}

// GET /trips — historique de l'utilisateur connecté (client ou chauffeur)
async function listTrips(req, res, next) {
  try {
    const { id, role } = req.user;
    const column = role === 'chauffeur' ? 'driver_id' : 'client_id';

    const { data, error } = await supabase
      .from('trips')
      .select('*')
      .eq(column, id)
      .order('created_at', { ascending: false });

    if (error) throw error;
    res.json({ trips: data });
  } catch (err) {
    next(err);
  }
}

// PATCH /trips/:id/accept — un chauffeur accepte la course
async function acceptTrip(req, res, next) {
  try {
    const driverId = req.user.id;
    const { data, error } = await supabase
      .from('trips')
      .update({ driver_id: driverId, status: 'acceptee', accepted_at: new Date().toISOString() })
      .eq('id', req.params.id)
      .eq('status', 'recherche_chauffeur')
      .select()
      .single();

    if (error || !data) {
      return res.status(409).json({ error: 'Course déjà prise ou indisponible.' });
    }
    res.json({ trip: data });
  } catch (err) {
    next(err);
  }
}

// PATCH /trips/:id/start
async function startTrip(req, res, next) {
  try {
    const { data, error } = await supabase
      .from('trips')
      .update({ status: 'en_cours', started_at: new Date().toISOString() })
      .eq('id', req.params.id)
      .eq('driver_id', req.user.id)
      .select()
      .single();

    if (error || !data) return res.status(409).json({ error: 'Impossible de démarrer cette course.' });
    res.json({ trip: data });
  } catch (err) {
    next(err);
  }
}

// PATCH /trips/:id/end
async function endTrip(req, res, next) {
  try {
    const { data, error } = await supabase
      .from('trips')
      .update({ status: 'terminee', ended_at: new Date().toISOString() })
      .eq('id', req.params.id)
      .eq('driver_id', req.user.id)
      .select()
      .single();

    if (error || !data) return res.status(409).json({ error: 'Impossible de terminer cette course.' });
    res.json({ trip: data });
  } catch (err) {
    next(err);
  }
}

// PATCH /trips/:id/cancel — client ou chauffeur
async function cancelTrip(req, res, next) {
  try {
    const { reason } = req.body;
    const { id: userId, role } = req.user;
    const status = role === 'chauffeur' ? 'annulee_chauffeur' : 'annulee_client';

    const { data, error } = await supabase
      .from('trips')
      .update({ status, cancel_reason: reason || null })
      .eq('id', req.params.id)
      .select()
      .single();

    if (error || !data) return res.status(404).json({ error: 'Course introuvable.' });
    res.json({ trip: data });
  } catch (err) {
    next(err);
  }
}

// POST /trips/:id/check-deviation — B8 : détecte un écart de trajet significatif
async function checkDeviation(req, res, next) {
  try {
    const { current_lat, current_lng, expected_lat, expected_lng, threshold_km = 1.5 } = req.body;

    // Distance approximative (formule haversine simplifiée)
    const toRad = (v) => (v * Math.PI) / 180;
    const R = 6371;
    const dLat = toRad(current_lat - expected_lat);
    const dLng = toRad(current_lng - expected_lng);
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(toRad(expected_lat)) * Math.cos(toRad(current_lat)) * Math.sin(dLng / 2) ** 2;
    const distanceKm = R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    const isDeviation = distanceKm > threshold_km;

    if (isDeviation) {
      await supabase.from('alerts').insert([{
        trip_id: req.params.id,
        user_id: req.user.id,
        type: 'deviation',
        lat: current_lat,
        lng: current_lng,
        details: `Écart détecté : ${distanceKm.toFixed(2)} km du trajet attendu`,
      }]);
    }

    res.json({ deviation_detected: isDeviation, distance_km: Number(distanceKm.toFixed(2)) });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  estimate, createTrip, getTrip, listTrips,
  acceptTrip, startTrip, endTrip, cancelTrip, checkDeviation,
};

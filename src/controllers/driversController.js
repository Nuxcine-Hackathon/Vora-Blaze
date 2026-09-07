const supabase = require('../config/supabase');

// PUT /drivers/status — { is_online: true/false }
async function setStatus(req, res, next) {
  try {
    const driverId = req.user.id;
    const { is_online } = req.body;

    const { data: vehicle } = await supabase.from('vehicles').select('id').eq('driver_id', driverId).maybeSingle();

    let result;
    if (vehicle) {
      const { data, error } = await supabase
        .from('vehicles')
        .update({ is_online })
        .eq('driver_id', driverId)
        .select()
        .single();
      if (error) throw error;
      result = data;
    } else {
      const { data, error } = await supabase
        .from('vehicles')
        .insert([{ driver_id: driverId, is_online }])
        .select()
        .single();
      if (error) throw error;
      result = data;
    }

    res.json({ vehicle: result });
  } catch (err) {
    next(err);
  }
}

// PUT /drivers/position — { lat, lng }
async function updatePosition(req, res, next) {
  try {
    const driverId = req.user.id;
    const { lat, lng } = req.body;

    const { data, error } = await supabase
      .from('vehicles')
      .update({ current_lat: lat, current_lng: lng, last_position_at: new Date().toISOString() })
      .eq('driver_id', driverId)
      .select()
      .single();

    if (error || !data) return res.status(404).json({ error: 'Véhicule non trouvé. Passez d\'abord en ligne.' });
    res.json({ vehicle: data });
  } catch (err) {
    next(err);
  }
}

// GET /drivers/nearby?lat=..&lng=..&radius_km=5&category=eco
// Version simple pour le MVP : filtre côté Node (pas de PostGIS requis)
async function nearby(req, res, next) {
  try {
    const { lat, lng, radius_km = 5, category } = req.query;
    if (!lat || !lng) return res.status(400).json({ error: 'lat et lng sont requis.' });

    let query = supabase.from('vehicles').select('*, users!vehicles_driver_id_fkey(nom, prenom)').eq('is_online', true);
    if (category) query = query.eq('category', category);

    const { data, error } = await query;
    if (error) throw error;

    const toRad = (v) => (v * Math.PI) / 180;
    const R = 6371;
    const withDistance = (data || [])
      .filter((v) => v.current_lat != null && v.current_lng != null)
      .map((v) => {
        const dLat = toRad(v.current_lat - lat);
        const dLng = toRad(v.current_lng - lng);
        const a =
          Math.sin(dLat / 2) ** 2 +
          Math.cos(toRad(Number(lat))) * Math.cos(toRad(v.current_lat)) * Math.sin(dLng / 2) ** 2;
        const distance_km = R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return { ...v, distance_km: Number(distance_km.toFixed(2)) };
      })
      .filter((v) => v.distance_km <= Number(radius_km))
      .sort((a, b) => a.distance_km - b.distance_km);

    res.json({ drivers: withDistance });
  } catch (err) {
    next(err);
  }
}

module.exports = { setStatus, updatePosition, nearby };

const supabase = require('../config/supabase');

// POST /ratings — { trip_id, rated_user, score, comment }
async function createRating(req, res, next) {
  try {
    const raterId = req.user.id;
    const { trip_id, rated_user, score, comment } = req.body;

    const { data, error } = await supabase
      .from('ratings')
      .insert([{ trip_id, rated_by: raterId, rated_user, score, comment }])
      .select()
      .single();

    if (error) throw error;
    res.status(201).json({ rating: data });
  } catch (err) {
    next(err);
  }
}

// GET /ratings/user/:userId — note moyenne + historique
async function getUserRatings(req, res, next) {
  try {
    const { data, error } = await supabase.from('ratings').select('*').eq('rated_user', req.params.userId);
    if (error) throw error;

    const average = data.length ? data.reduce((sum, r) => sum + r.score, 0) / data.length : null;
    res.json({ average_rating: average, count: data.length, ratings: data });
  } catch (err) {
    next(err);
  }
}

module.exports = { createRating, getUserRatings };

const supabase = require('../config/supabase');

// GET /users/me — profil de l'utilisateur connecté (client, chauffeur ou admin)
async function getMe(req, res, next) {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('id, role, nom, prenom, telephone, email, is_active, created_at')
      .eq('id', req.user.id)
      .single();

    if (error || !data) return res.status(404).json({ error: 'Utilisateur introuvable.' });
    res.json({ user: data });
  } catch (err) {
    next(err);
  }
}

module.exports = { getMe };

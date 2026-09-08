const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const supabase = require('../config/supabase');

function generateOtp() {
  return String(Math.floor(100000 + Math.random() * 900000)); // OTP simulé à 6 chiffres
}

function signToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role, telephone: user.telephone },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

// POST /register
async function register(req, res, next) {
  try {
    const { role = 'client', nom, prenom, telephone, email, password } = req.body;

    const { data: existing } = await supabase
      .from('users')
      .select('id')
      .eq('telephone', telephone)
      .maybeSingle();

    if (existing) {
      return res.status(409).json({ error: 'Un compte existe déjà avec ce numéro.' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const otp_code = generateOtp();

    const { data, error } = await supabase
      .from('users')
      .insert([{ role, nom, prenom, telephone, email, password_hash, otp_code, otp_verified: false }])
      .select('id, role, nom, prenom, telephone')
      .single();

    if (error) throw error;

    // OTP simulé : on le renvoie directement dans la réponse pour la démo
    // (en prod : envoi réel par SMS via Twilio, voir §6 de la fiche de suivi).
    res.status(201).json({
      message: 'Compte créé. Vérifiez le code OTP (simulé ci-dessous) pour activer le compte.',
      user_id: data.id,
      otp_code_demo: otp_code,
    });
  } catch (err) {
    next(err);
  }
}

// POST /verify-otp
async function verifyOtp(req, res, next) {
  try {
    const { telephone, otp_code } = req.body;

    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('telephone', telephone)
      .maybeSingle();

    if (error) throw error;
    if (!user) return res.status(404).json({ error: 'Utilisateur introuvable.' });
    if (user.otp_verified) return res.status(400).json({ error: 'Compte déjà vérifié.' });
    if (user.otp_code !== otp_code) return res.status(400).json({ error: 'Code OTP incorrect.' });

    await supabase.from('users').update({ otp_verified: true, otp_code: null }).eq('id', user.id);

    const token = signToken(user);
    res.json({ message: 'Compte vérifié.', token, user: { id: user.id, role: user.role, nom: user.nom, prenom: user.prenom } });
  } catch (err) {
    next(err);
  }
}

// POST /login
async function login(req, res, next) {
  try {
    const { telephone, password } = req.body;

    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('telephone', telephone)
      .maybeSingle();

    if (error) throw error;
    if (!user) return res.status(401).json({ error: 'Identifiants invalides.' });
    if (!user.is_active) return res.status(403).json({ error: 'Compte suspendu.' });
    if (!user.otp_verified) return res.status(403).json({ error: 'Compte non vérifié. Vérifiez votre OTP.' });

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Identifiants invalides.' });

    const token = signToken(user);
    res.json({
      token,
      user: { id: user.id, role: user.role, nom: user.nom, prenom: user.prenom, telephone: user.telephone },
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { register, verifyOtp, login };

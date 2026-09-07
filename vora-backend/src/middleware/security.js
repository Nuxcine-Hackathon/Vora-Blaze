const rateLimit = require('express-rate-limit');

// Limite générale : 100 requêtes / 15 min / IP
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Trop de requêtes, réessayez dans quelques minutes.' },
});

// Limite stricte pour l'auth (anti brute-force sur /login, /verify-otp)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Trop de tentatives de connexion, réessayez plus tard.' },
});

module.exports = { generalLimiter, authLimiter };

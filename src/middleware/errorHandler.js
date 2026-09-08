const { validationResult } = require('express-validator');

// À placer après chaque bloc de règles express-validator dans une route
function handleValidation(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: 'Données invalides', details: errors.array() });
  }
  next();
}

// Handler global — placé en tout dernier dans server.js
// Ne jamais renvoyer la stack trace brute en prod (pas de fuite d'infos internes).
function errorHandler(err, req, res, next) {
  console.error('[vora] Erreur:', err.message);
  const status = err.status || 500;
  res.status(status).json({
    error: status === 500 ? 'Erreur interne du serveur' : err.message,
  });
}

function notFound(req, res) {
  res.status(404).json({ error: `Route inconnue : ${req.method} ${req.originalUrl}` });
}

module.exports = { handleValidation, errorHandler, notFound };

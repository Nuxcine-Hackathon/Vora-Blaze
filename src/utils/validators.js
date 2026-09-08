const { body, query } = require('express-validator');

const registerRules = [
  body('nom').trim().notEmpty().withMessage('nom requis'),
  body('prenom').trim().notEmpty().withMessage('prenom requis'),
  body('telephone').trim().notEmpty().withMessage('telephone requis'),
  body('password').isLength({ min: 6 }).withMessage('mot de passe : 6 caractères minimum'),
  body('role').optional().isIn(['client', 'chauffeur', 'admin']),
  body('email').optional({ nullable: true, checkFalsy: true }).isEmail().withMessage('email invalide'),
];

const verifyOtpRules = [
  body('telephone').trim().notEmpty(),
  body('otp_code').trim().notEmpty(),
];

const loginRules = [
  body('telephone').trim().notEmpty(),
  body('password').notEmpty(),
];

const estimateRules = [
  body('distance_km').isFloat({ gt: 0 }).withMessage('distance_km doit être un nombre positif'),
  body('vehicle_category').optional().isIn(['eco', 'confort', 'xl', 'pmr']),
];

const createTripRules = [
  body('destination_zone').trim().notEmpty(),
  body('distance_km').isFloat({ gt: 0 }),
  body('vehicle_category').optional().isIn(['eco', 'confort', 'xl', 'pmr']),
];

const nearbyRules = [
  query('lat').isFloat().withMessage('lat requis'),
  query('lng').isFloat().withMessage('lng requis'),
];

const sosRules = [
  body('lat').optional().isFloat(),
  body('lng').optional().isFloat(),
];

const assistantRules = [
  body('message').trim().notEmpty().withMessage('message requis'),
];

module.exports = {
  registerRules, verifyOtpRules, loginRules,
  estimateRules, createTripRules, nearbyRules, sosRules, assistantRules,
};

const express = require('express');
const router = express.Router();
const drivers = require('../controllers/driversController');
const { requireAuth, requireRole } = require('../middleware/auth');
const { handleValidation } = require('../middleware/errorHandler');
const { nearbyRules } = require('../utils/validators');

router.put('/status', requireAuth, requireRole('chauffeur'), drivers.setStatus);
router.put('/position', requireAuth, requireRole('chauffeur'), drivers.updatePosition);
router.get('/nearby', requireAuth, nearbyRules, handleValidation, drivers.nearby);

module.exports = router;

const express = require('express');
const router = express.Router();
const alerts = require('../controllers/alertsController');
const { requireAuth, requireRole } = require('../middleware/auth');
const { handleValidation } = require('../middleware/errorHandler');
const { sosRules } = require('../utils/validators');

router.post('/sos', requireAuth, sosRules, handleValidation, alerts.triggerSos);
router.get('/', requireAuth, requireRole('admin'), alerts.listAlerts);
router.patch('/:id/resolve', requireAuth, requireRole('admin'), alerts.resolveAlert);

module.exports = router;

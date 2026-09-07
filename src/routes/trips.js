const express = require('express');
const router = express.Router();
const trips = require('../controllers/tripsController');
const { requireAuth, requireRole } = require('../middleware/auth');
const { handleValidation } = require('../middleware/errorHandler');
const { estimateRules, createTripRules } = require('../utils/validators');

router.post('/estimate', requireAuth, estimateRules, handleValidation, trips.estimate);
router.post('/', requireAuth, requireRole('client'), createTripRules, handleValidation, trips.createTrip);
router.get('/', requireAuth, trips.listTrips);
router.get('/pending', requireAuth, requireRole('chauffeur'), trips.listPendingTrips);
router.get('/:id', requireAuth, trips.getTrip);
router.patch('/:id/accept', requireAuth, requireRole('chauffeur'), trips.acceptTrip);
router.patch('/:id/start', requireAuth, requireRole('chauffeur'), trips.startTrip);
router.patch('/:id/end', requireAuth, requireRole('chauffeur'), trips.endTrip);
router.patch('/:id/cancel', requireAuth, trips.cancelTrip);
router.post('/:id/check-deviation', requireAuth, trips.checkDeviation);

module.exports = router;

const express = require('express');
const router = express.Router();
const payments = require('../controllers/paymentsController');
const { requireAuth } = require('../middleware/auth');

router.post('/', requireAuth, payments.createPayment);
router.get('/:tripId', requireAuth, payments.getPaymentByTrip);

module.exports = router;

const express = require('express');
const router = express.Router();
const ratings = require('../controllers/ratingsController');
const { requireAuth } = require('../middleware/auth');

router.post('/', requireAuth, ratings.createRating);
router.get('/user/:userId', ratings.getUserRatings);

module.exports = router;

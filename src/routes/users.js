const express = require('express');
const router = express.Router();
const { getMe } = require('../controllers/usersController');
const { requireAuth } = require('../middleware/auth');

router.get('/me', requireAuth, getMe);

module.exports = router;

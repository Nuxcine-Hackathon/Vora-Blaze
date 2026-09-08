const express = require('express');
const router = express.Router();
const { register, verifyOtp, login } = require('../controllers/authController');
const { handleValidation } = require('../middleware/errorHandler');
const { registerRules, verifyOtpRules, loginRules } = require('../utils/validators');
const { authLimiter } = require('../middleware/security');

router.post('/register', authLimiter, registerRules, handleValidation, register);
router.post('/verify-otp', authLimiter, verifyOtpRules, handleValidation, verifyOtp);
router.post('/login', authLimiter, loginRules, handleValidation, login);

module.exports = router;

const express = require('express');
const router = express.Router();
const { askAssistant } = require('../controllers/assistantController');
const { requireAuth } = require('../middleware/auth');
const { handleValidation } = require('../middleware/errorHandler');
const { assistantRules } = require('../utils/validators');

router.post('/', requireAuth, assistantRules, handleValidation, askAssistant);

module.exports = router;

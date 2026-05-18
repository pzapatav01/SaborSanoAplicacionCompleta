const express = require('express');
const router = express.Router();

const { authenticate } = require('../middleware/authMiddleware');
const { createIntent } = require('../controllers/payments.controller');

// POST /api/payments/create-intent
router.post('/create-intent', authenticate, createIntent);

module.exports = router;


require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const { generalLimiter } = require('./middleware/security');
const { errorHandler, notFound } = require('./middleware/errorHandler');

const healthRoutes = require('./routes/health');
const authRoutes = require('./routes/auth');
const tripsRoutes = require('./routes/trips');
const driversRoutes = require('./routes/drivers');
const paymentsRoutes = require('./routes/payments');
const ratingsRoutes = require('./routes/ratings');
const alertsRoutes = require('./routes/alerts');
const assistantRoutes = require('./routes/assistant');

const app = express();

// --- Sécurité (B10) ---
app.use(helmet());
const allowedOrigins = (process.env.CORS_ORIGIN || '*').split(',').map((o) => o.trim());
app.use(cors({ origin: allowedOrigins }));
app.use(generalLimiter);

// --- Parsing & logs ---
app.use(express.json({ limit: '1mb' }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// --- Routes ---
app.use('/health', healthRoutes);
app.use('/auth', authRoutes);           // /auth/register, /auth/verify-otp, /auth/login
app.use('/trips', tripsRoutes);         // /trips/estimate, POST /trips, /trips/:id/*
app.use('/drivers', driversRoutes);     // /drivers/status, /drivers/position, /drivers/nearby
app.use('/payments', paymentsRoutes);   // /payments
app.use('/ratings', ratingsRoutes);     // /ratings
app.use('/alerts', alertsRoutes);       // /alerts/sos
app.use('/assistant', assistantRoutes); // /assistant

// --- 404 + gestion d'erreurs centralisée ---
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`[vora] Backend démarré sur http://localhost:${PORT}`);
  console.log(`[vora] Health check : http://localhost:${PORT}/health`);
});

module.exports = app;

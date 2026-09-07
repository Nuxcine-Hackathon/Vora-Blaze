// Formule du cahier des charges : P = B (base) + αD (distance) + βT (durée) + S (ajustement)
const CATEGORY_COEFFICIENTS = {
  eco: { base: 500, perKm: 150, perMin: 25, categoryMultiplier: 1 },
  confort: { base: 800, perKm: 200, perMin: 35, categoryMultiplier: 1.3 },
  xl: { base: 1000, perKm: 220, perMin: 40, categoryMultiplier: 1.5 },
  pmr: { base: 700, perKm: 150, perMin: 25, categoryMultiplier: 1.1 },
};

// Approximation simple : vitesse moyenne 22 km/h en ville (ajustable selon traffic_score plus tard)
const AVERAGE_SPEED_KMH = 22;

function estimateDurationMin(distanceKm, trafficLevel = 'normal') {
  const trafficFactor = { faible: 0.8, normal: 1, eleve: 1.4, tres_eleve: 1.8 }[trafficLevel] || 1;
  return Math.round((distanceKm / AVERAGE_SPEED_KMH) * 60 * trafficFactor);
}

function calculatePrice({ distanceKm, category = 'eco', trafficLevel = 'normal', surge = 0 }) {
  const coeffs = CATEGORY_COEFFICIENTS[category] || CATEGORY_COEFFICIENTS.eco;
  const durationMin = estimateDurationMin(distanceKm, trafficLevel);

  const base = coeffs.base;
  const distanceCost = coeffs.perKm * distanceKm;
  const durationCost = coeffs.perMin * durationMin;
  const adjustment = surge; // S : ajustement éventuel (promo, forte demande, etc.)

  const rawPrice = (base + distanceCost + durationCost) * coeffs.categoryMultiplier + adjustment;

  // Arrondi au multiple de 50 FCFA le plus proche, prix minimum garanti
  const rounded = Math.max(500, Math.round(rawPrice / 50) * 50);

  return { price: rounded, durationMin };
}

module.exports = { calculatePrice, estimateDurationMin, CATEGORY_COEFFICIENTS };

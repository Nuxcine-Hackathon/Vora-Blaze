const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  // On ne fait pas planter le process ici : /health doit pouvoir répondre
  // même si Supabase n'est pas encore configuré (utile en tout début de setup, B2).
  console.warn(
    '[vora] ATTENTION: SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY manquant(s). ' +
    'Complétez votre fichier .env (voir .env.example).'
  );
}

const supabase = createClient(
  SUPABASE_URL || 'https://placeholder.supabase.co',
  SUPABASE_SERVICE_ROLE_KEY || 'placeholder-key',
  { auth: { persistSession: false } }
);

module.exports = supabase;

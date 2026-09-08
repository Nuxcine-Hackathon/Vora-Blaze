-- ============================================================
-- VORA — Schéma Supabase (Hackathon NuxCine 2026, Équipe Blaze)
-- 7 tables : users, vehicles, trips, payments, ratings, alerts, assistant_logs
-- À exécuter dans Supabase > SQL Editor
-- ============================================================

create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- 1. USERS (clients + chauffeurs + admin, distingués par "role")
-- ------------------------------------------------------------
create table if not exists users (
  id uuid primary key default uuid_generate_v4(),
  role text not null check (role in ('client', 'chauffeur', 'admin')),
  nom text not null,
  prenom text not null,
  telephone text not null unique,
  email text unique,
  password_hash text not null,
  otp_code text,
  otp_verified boolean default false,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 2. VEHICLES (1 véhicule + statut de disponibilité par chauffeur)
-- ------------------------------------------------------------
create table if not exists vehicles (
  id uuid primary key default uuid_generate_v4(),
  driver_id uuid not null references users(id) on delete cascade,
  category text not null default 'eco' check (category in ('eco', 'confort', 'xl', 'pmr')),
  plate_number text,
  brand text,
  model text,
  is_online boolean default false,
  current_lat double precision,
  current_lng double precision,
  last_position_at timestamptz,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 3. TRIPS (courses)
-- ------------------------------------------------------------
create table if not exists trips (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid not null references users(id),
  driver_id uuid references users(id),
  pickup_zone text,
  pickup_lat double precision,
  pickup_lng double precision,
  pickup_landmark text,
  destination_zone text,
  destination_lat double precision,
  destination_lng double precision,
  vehicle_category text default 'eco',
  distance_km double precision,
  duration_min double precision,
  estimated_price numeric,
  locked_price numeric,
  status text not null default 'estimation' check (status in (
    'estimation', 'recherche_chauffeur', 'acceptee', 'chauffeur_en_route',
    'chauffeur_arrive', 'en_cours', 'terminee', 'annulee_client',
    'annulee_chauffeur', 'aucun_chauffeur', 'incident'
  )),
  cancel_reason text,
  created_at timestamptz default now(),
  accepted_at timestamptz,
  started_at timestamptz,
  ended_at timestamptz
);

-- ------------------------------------------------------------
-- 4. PAYMENTS
-- ------------------------------------------------------------
create table if not exists payments (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  amount numeric not null,
  method text not null default 'especes' check (method in ('especes', 'mobile_money', 'carte', 'wallet')),
  status text not null default 'en_attente' check (status in ('en_attente', 'confirme', 'echoue', 'rembourse')),
  simulated boolean default true,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 5. RATINGS (évaluations client <-> chauffeur)
-- ------------------------------------------------------------
create table if not exists ratings (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid not null references trips(id) on delete cascade,
  rated_by uuid not null references users(id),
  rated_user uuid not null references users(id),
  score int not null check (score between 1 and 5),
  comment text,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 6. ALERTS (SOS + écart de trajet)
-- ------------------------------------------------------------
create table if not exists alerts (
  id uuid primary key default uuid_generate_v4(),
  trip_id uuid references trips(id) on delete cascade,
  user_id uuid not null references users(id),
  type text not null check (type in ('sos', 'deviation', 'incident')),
  lat double precision,
  lng double precision,
  details text,
  resolved boolean default false,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 7. ASSISTANT_LOGS (journal des échanges avec l'assistant IA)
-- ------------------------------------------------------------
create table if not exists assistant_logs (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references users(id),
  trip_id uuid references trips(id),
  message text not null,
  detected_intent text,
  response text,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- Index utiles
-- ------------------------------------------------------------
create index if not exists idx_trips_client on trips(client_id);
create index if not exists idx_trips_driver on trips(driver_id);
create index if not exists idx_trips_status on trips(status);
create index if not exists idx_vehicles_online on vehicles(is_online);
create index if not exists idx_payments_trip on payments(trip_id);
create index if not exists idx_alerts_user on alerts(user_id);

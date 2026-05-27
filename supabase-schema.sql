-- ============================================================
-- Sales Follow-Up Portal — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ──────────────────────────────────────────────
-- CUSTOMERS TABLE
-- ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.customers (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  name               TEXT NOT NULL,
  mobile             TEXT NOT NULL,
  product_model      TEXT NOT NULL,
  remarks            TEXT DEFAULT '',
  status             TEXT NOT NULL DEFAULT 'New'
                       CHECK (status IN ('New', 'Interested', 'Hot', 'Closed')),
  next_followup_date DATE,
  created_by         TEXT  -- stores user email
);

-- ──────────────────────────────────────────────
-- FOLLOW-UPS TABLE
-- ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.follow_ups (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  customer_id        UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  comment            TEXT NOT NULL,
  status             TEXT NOT NULL DEFAULT 'New'
                       CHECK (status IN ('New', 'Interested', 'Hot', 'Closed')),
  next_followup_date DATE,
  created_by         TEXT  -- stores user email
);

-- ──────────────────────────────────────────────
-- INDEXES
-- ──────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_customers_status        ON public.customers(status);
CREATE INDEX IF NOT EXISTS idx_customers_followup_date ON public.customers(next_followup_date);
CREATE INDEX IF NOT EXISTS idx_customers_created_at    ON public.customers(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_followups_customer_id   ON public.follow_ups(customer_id);
CREATE INDEX IF NOT EXISTS idx_followups_created_at    ON public.follow_ups(created_at DESC);

-- ──────────────────────────────────────────────
-- AUTO-UPDATE updated_at TRIGGER
-- ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_customers_updated_at ON public.customers;
CREATE TRIGGER set_customers_updated_at
  BEFORE UPDATE ON public.customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ──────────────────────────────────────────────
-- ROW LEVEL SECURITY (RLS)
-- ──────────────────────────────────────────────
-- Enable RLS
ALTER TABLE public.customers  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follow_ups ENABLE ROW LEVEL SECURITY;

-- Policy: any authenticated user can SELECT, INSERT, UPDATE, DELETE
-- (This suits a small team sharing all customer data)

DROP POLICY IF EXISTS "Authenticated users can read customers"  ON public.customers;
DROP POLICY IF EXISTS "Authenticated users can insert customers" ON public.customers;
DROP POLICY IF EXISTS "Authenticated users can update customers" ON public.customers;
DROP POLICY IF EXISTS "Authenticated users can delete customers" ON public.customers;

CREATE POLICY "Authenticated users can read customers"
  ON public.customers FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Authenticated users can insert customers"
  ON public.customers FOR INSERT
  TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can update customers"
  ON public.customers FOR UPDATE
  TO authenticated USING (true);

CREATE POLICY "Authenticated users can delete customers"
  ON public.customers FOR DELETE
  TO authenticated USING (true);

-- Follow-ups policies
DROP POLICY IF EXISTS "Authenticated users can read follow_ups"   ON public.follow_ups;
DROP POLICY IF EXISTS "Authenticated users can insert follow_ups"  ON public.follow_ups;
DROP POLICY IF EXISTS "Authenticated users can delete follow_ups"  ON public.follow_ups;

CREATE POLICY "Authenticated users can read follow_ups"
  ON public.follow_ups FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Authenticated users can insert follow_ups"
  ON public.follow_ups FOR INSERT
  TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can delete follow_ups"
  ON public.follow_ups FOR DELETE
  TO authenticated USING (true);

-- ──────────────────────────────────────────────
-- SAMPLE DATA (optional — remove before production)
-- ──────────────────────────────────────────────
-- INSERT INTO public.customers (name, mobile, product_model, remarks, status, next_followup_date, created_by)
-- VALUES
--   ('Rajesh Kumar',   '9876543210', 'Samsung Galaxy S24',  'Very interested, wants EMI',   'Hot',        CURRENT_DATE,       'admin@yourcompany.com'),
--   ('Priya Sharma',   '9123456789', 'iPhone 15 Pro',       'Comparing with OnePlus',       'Interested', CURRENT_DATE + 2,   'admin@yourcompany.com'),
--   ('Arun Selvam',    '9988776655', 'Sony Bravia 65" TV',  'Budget concern, revisit',      'New',        CURRENT_DATE + 5,   'admin@yourcompany.com'),
--   ('Meena Rajan',    '9871234560', 'LG Washing Machine',  'Ready to buy, confirm colour', 'Hot',        CURRENT_DATE,       'admin@yourcompany.com'),
--   ('Vikram Nair',    '9445566778', 'Bosch Refrigerator',  'Closed last week',             'Closed',     NULL,               'admin@yourcompany.com');

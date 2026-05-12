-- ============================================================
-- TBC TRACKER — Supabase Database Schema
-- Jalankan script ini di Supabase Dashboard → SQL Editor
-- ============================================================

-- ─── 1. Tabel Profiles ────────────────────────────────────────────────────────
-- Menyimpan data profil pengguna, extends tabel auth.users bawaan Supabase
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name        TEXT NOT NULL,
  email       TEXT NOT NULL,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ─── 2. Tabel Schedules ───────────────────────────────────────────────────────
-- Menyimpan jadwal minum obat per pengguna
CREATE TABLE IF NOT EXISTS schedules (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id       UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  start_day     INT NOT NULL CHECK (start_day > 0),
  target_day    INT NOT NULL CHECK (target_day > start_day),
  reminder_time TEXT,
  is_daily      BOOLEAN DEFAULT TRUE NOT NULL,
  selected_days TEXT[] DEFAULT '{}',
  created_at    TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at    TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ─── 3. Tabel Checkup Logs ────────────────────────────────────────────────────
-- Menyimpan log hasil checkup harian
CREATE TABLE IF NOT EXISTS checkup_logs (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  answers     JSONB NOT NULL DEFAULT '{}',
  is_critical BOOLEAN DEFAULT FALSE NOT NULL,
  has_warning BOOLEAN DEFAULT FALSE NOT NULL,
  checked_at  TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Setiap user hanya bisa mengakses data milik mereka sendiri
-- ============================================================

-- Aktifkan RLS
ALTER TABLE profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules    ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkup_logs ENABLE ROW LEVEL SECURITY;

-- ─── Policy: Profiles ─────────────────────────────────────────────────────────
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- ─── Policy: Schedules ────────────────────────────────────────────────────────
CREATE POLICY "Users can manage own schedules"
  ON schedules FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─── Policy: Checkup Logs ─────────────────────────────────────────────────────
CREATE POLICY "Users can manage own checkup logs"
  ON checkup_logs FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SUPABASE STORAGE — Bucket untuk foto profil
-- ============================================================
-- Buat bucket "avatars" (public) di Supabase Dashboard:
-- Storage → New Bucket → Name: avatars → Public: ON
--
-- Atau jalankan SQL ini (perlu extension storage):
-- INSERT INTO storage.buckets (id, name, public) 
--   VALUES ('avatars', 'avatars', true)
-- ON CONFLICT DO NOTHING;

-- Policy storage: user hanya bisa upload/hapus foto miliknya sendiri
-- (Jalankan di Supabase Dashboard → Storage → Policies → avatars)
--
-- INSERT INTO storage.policies (name, bucket_id, operation, definition) VALUES
--   ('Users can upload own avatar', 'avatars', 'INSERT',
--    '(bucket_id = ''avatars'' AND auth.uid()::text = (storage.foldername(name))[1])'),
--   ('Users can update own avatar', 'avatars', 'UPDATE',
--    '(bucket_id = ''avatars'' AND auth.uid()::text = (storage.foldername(name))[1])'),
--   ('Users can delete own avatar', 'avatars', 'DELETE',
--    '(bucket_id = ''avatars'' AND auth.uid()::text = (storage.foldername(name))[1])'),
--   ('Anyone can view avatars', 'avatars', 'SELECT', 'true');

-- ─── 4. Tabel Medication Logs ──────────────────────────────────────────────────
-- Menyimpan log riwayat minum obat harian untuk fitur streak
CREATE TABLE IF NOT EXISTS medication_logs (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  taken_date DATE NOT NULL,
  taken_at   TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, taken_date) -- Memastikan 1 log per user per hari
);

ALTER TABLE medication_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own medication logs"
  ON medication_logs FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- TSF27 - Teaching Service Commission Form 27
-- Supabase PostgreSQL Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLE: teacher_profiles
-- Extends Supabase auth.users
-- ============================================================
CREATE TABLE public.teacher_profiles (
  id          UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email       TEXT,
  full_name   TEXT,
  role        TEXT DEFAULT 'teacher' CHECK (role IN ('teacher', 'admin', 'tsc_officer')),
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLE: form27_submissions
-- Stores all Form 27 (TSF27) data
-- ============================================================
CREATE TABLE public.form27_submissions (
  id      UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status  TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'approved', 'rejected')),

  -- HEADER
  sector  TEXT CHECK (sector IN ('ELM/ECE','PRIM','HIGH/SEC','VET','NSOE','IERC','FODE')),

  -- SECTION 1: Personal Details
  first_name            TEXT,
  sur_name              TEXT,
  gender                TEXT CHECK (gender IN ('M','F')),
  date_of_birth         DATE,
  marital_status        TEXT CHECK (marital_status IN ('Married','Single','Separated','Divorced','Widowed')),
  nid_birth_cert_no     TEXT,
  nationality           TEXT,
  religion              TEXT,
  mobile_no             TEXT,
  pay_method_account    TEXT,
  appointment_status    TEXT CHECK (appointment_status IN ('Serving Teacher','Acting','Tenure')),
  teaching_position     TEXT,
  prov_sch_code_pos     TEXT,
  sub_eligibility_status TEXT,
  current_fn            TEXT,
  year_last_inspection  TEXT,
  is_new_hire           BOOLEAN DEFAULT FALSE,

  -- SECTION 2: Place of Origin
  home_village    TEXT,
  home_province   TEXT,
  home_district   TEXT,
  home_llg        TEXT,

  -- SECTION 3a: Spouse Information
  spouse_name         TEXT,
  spouse_dob          DATE,
  spouse_employer     TEXT,
  spouse_employer_no  TEXT,
  spouse_home_province TEXT,
  spouse_home_district TEXT,
  spouse_home_village  TEXT,
  no_of_dependents     INTEGER DEFAULT 0,

  -- SECTION 3b: Dependents (JSONB array)
  -- Format: [{"name":"...", "dob":"...", "relationship":"..."}, ...]
  dependents JSONB DEFAULT '[]'::JSONB,

  -- SECTION 4: Qualifications
  highest_qualification      TEXT CHECK (highest_qualification IN ('MASTER','DEGREE','DIPLOMA','CERT')),
  institution_graduated      TEXT,
  year_of_completion         TEXT,
  other_qualification        TEXT,
  teacher_reg_cert_status    TEXT CHECK (teacher_reg_cert_status IN ('Expired','Full','Current')),
  teacher_reg_cert_detail    TEXT,
  school_grade_10_12         TEXT,
  year_completion_grade_12   TEXT,
  school_fode_dodl           TEXT,
  year_completion_grade_10   TEXT,

  -- SECTION 5: Teaching Position / Appointment
  teaching_prov           TEXT,
  teaching_location       TEXT,
  start_date              DATE,
  long_leave_duration     TEXT,
  resumption_after_leave  TEXT,

  -- SECTION 6: Affirmation
  affirmation_name   TEXT,
  affirmation_signed BOOLEAN DEFAULT FALSE,
  affirmation_date   DATE,
  witness_name       TEXT,

  -- SECTION 7: Certification
  certification_signed BOOLEAN DEFAULT FALSE,
  certification_date   DATE,

  -- SECTION 8: TSC Decision (admin only)
  tsc_decision        TEXT CHECK (tsc_decision IN ('Approved','Not Approved')),
  admission_id_number TEXT,
  approval_type       TEXT CHECK (approval_type IN ('Provisional','Full')),
  tsc_commissioner    TEXT,

  -- Timestamps
  submitted_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.teacher_profiles   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.form27_submissions ENABLE ROW LEVEL SECURITY;

-- teacher_profiles policies
CREATE POLICY "Users can view own profile"
  ON public.teacher_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.teacher_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.teacher_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can manage all profiles"
  ON public.teacher_profiles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.teacher_profiles
      WHERE id = auth.uid() AND role IN ('admin','tsc_officer')
    )
  );

-- form27_submissions policies
CREATE POLICY "Users can view own submissions"
  ON public.form27_submissions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own submissions"
  ON public.form27_submissions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own draft submissions"
  ON public.form27_submissions FOR UPDATE
  USING (auth.uid() = user_id AND status = 'draft');

CREATE POLICY "Admins can manage all submissions"
  ON public.form27_submissions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.teacher_profiles
      WHERE id = auth.uid() AND role IN ('admin','tsc_officer')
    )
  );

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-create profile on new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.teacher_profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_profiles
  BEFORE UPDATE ON public.teacher_profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

CREATE TRIGGER set_updated_at_submissions
  BEFORE UPDATE ON public.form27_submissions
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

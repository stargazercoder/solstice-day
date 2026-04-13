-- ============================================================
-- Migration: Add Notebook Tables
-- ============================================================

-- 13. NOTEBOOK SECTIONS (Not Defteri Bölümleri)
CREATE TABLE IF NOT EXISTS public.notebook_sections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'notes',
  color TEXT NOT NULL DEFAULT '#3B82F6',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. NOTEBOOK ENTRIES (Not Defteri Kayıtları)
CREATE TABLE IF NOT EXISTS public.notebook_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  section_id UUID NOT NULL REFERENCES public.notebook_sections(id) ON DELETE CASCADE,
  title TEXT,
  content TEXT,
  entry_type TEXT DEFAULT 'text' CHECK (entry_type IN ('text', 'checklist')),
  checklist_items JSONB DEFAULT '[]',
  is_pinned BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_notebook_sections_user ON public.notebook_sections(user_id);
CREATE INDEX IF NOT EXISTS idx_notebook_entries_user ON public.notebook_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_notebook_entries_section ON public.notebook_entries(section_id);

-- RLS for Notebook
ALTER TABLE public.notebook_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notebook_entries ENABLE ROW LEVEL SECURITY;

-- Notebook Sections Policies
DROP POLICY IF EXISTS "Users can manage own sections" ON public.notebook_sections;
CREATE POLICY "Users can manage own sections" ON public.notebook_sections FOR ALL USING (auth.uid() = user_id);

-- Notebook Entries Policies
DROP POLICY IF EXISTS "Users can manage own entries" ON public.notebook_entries;
CREATE POLICY "Users can manage own entries" ON public.notebook_entries FOR ALL USING (auth.uid() = user_id);

-- Trigger for notebook_sections updated_at
DROP TRIGGER IF EXISTS update_notebook_sections_updated_at ON public.notebook_sections;
CREATE TRIGGER update_notebook_sections_updated_at BEFORE UPDATE ON public.notebook_sections
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Trigger for notebook_entries updated_at
DROP TRIGGER IF EXISTS update_notebook_entries_updated_at ON public.notebook_entries;
CREATE TRIGGER update_notebook_entries_updated_at BEFORE UPDATE ON public.notebook_entries
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

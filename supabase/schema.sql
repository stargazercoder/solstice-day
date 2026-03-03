-- ============================================================
-- HABITRA - Alışkanlık Takip Uygulaması
-- Supabase Database Schema
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. PROFILES (Kullanıcı Profilleri)
-- ============================================================
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  timezone TEXT DEFAULT 'Europe/Istanbul',
  notification_enabled BOOLEAN DEFAULT true,
  notification_hour INT DEFAULT 9 CHECK (notification_hour >= 0 AND notification_hour <= 23),
  streak_record INT DEFAULT 0,
  total_completed INT DEFAULT 0,
  level INT DEFAULT 1,
  xp INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. MANAGED PROFILES (Takip Edilen Profiller - çocuk, eş vb.)
-- ============================================================
CREATE TABLE public.managed_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  avatar_url TEXT,
  relationship TEXT DEFAULT 'other', -- child, spouse, parent, other
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. HABIT CATEGORIES (Alışkanlık Kategorileri)
-- ============================================================
CREATE TABLE public.habit_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_tr TEXT NOT NULL,
  name_en TEXT NOT NULL,
  icon TEXT NOT NULL,       -- Material icon name
  color TEXT NOT NULL,      -- Hex color
  sort_order INT DEFAULT 0
);

-- Varsayılan kategoriler
INSERT INTO public.habit_categories (name_tr, name_en, icon, color, sort_order) VALUES
  ('Sağlık', 'Health', 'favorite', '#EF4444', 1),
  ('Fitness', 'Fitness', 'fitness_center', '#F97316', 2),
  ('Beslenme', 'Nutrition', 'restaurant', '#84CC16', 3),
  ('Zihinsel Sağlık', 'Mental Health', 'self_improvement', '#8B5CF6', 4),
  ('Üretkenlik', 'Productivity', 'trending_up', '#3B82F6', 5),
  ('Eğitim', 'Education', 'school', '#06B6D4', 6),
  ('Sosyal', 'Social', 'people', '#EC4899', 7),
  ('Finans', 'Finance', 'savings', '#10B981', 8),
  ('Yaratıcılık', 'Creativity', 'palette', '#F59E0B', 9),
  ('Kişisel Bakım', 'Self Care', 'spa', '#14B8A6', 10);

-- ============================================================
-- 4. PRESET HABITS (Hazır Alışkanlıklar)
-- ============================================================
CREATE TABLE public.preset_habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID REFERENCES public.habit_categories(id),
  name_tr TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_tr TEXT,
  description_en TEXT,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  default_frequency TEXT DEFAULT 'daily', -- daily, weekly, custom
  default_target_count INT DEFAULT 1,
  default_unit TEXT,                       -- bardak, dakika, sayfa, vs.
  is_popular BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0
);

-- Popüler hazır alışkanlıklar
INSERT INTO public.preset_habits (category_id, name_tr, name_en, description_tr, icon, color, default_frequency, default_target_count, default_unit, is_popular, sort_order) VALUES
  ((SELECT id FROM habit_categories WHERE name_en='Health'), 'Su İç', 'Drink Water', 'Günlük su tüketimini takip et', 'water_drop', '#3B82F6', 'daily', 8, 'bardak', true, 1),
  ((SELECT id FROM habit_categories WHERE name_en='Fitness'), 'Egzersiz Yap', 'Exercise', 'Düzenli egzersiz yap', 'fitness_center', '#EF4444', 'daily', 30, 'dakika', true, 2),
  ((SELECT id FROM habit_categories WHERE name_en='Education'), 'Kitap Oku', 'Read Book', 'Her gün kitap oku', 'menu_book', '#8B5CF6', 'daily', 20, 'sayfa', true, 3),
  ((SELECT id FROM habit_categories WHERE name_en='Mental Health'), 'Meditasyon', 'Meditation', 'Zihnini dinlendir', 'self_improvement', '#10B981', 'daily', 10, 'dakika', true, 4),
  ((SELECT id FROM habit_categories WHERE name_en='Health'), 'Erken Kalk', 'Wake Up Early', 'Sabah erken uyan', 'alarm', '#F97316', 'daily', 1, NULL, true, 5),
  ((SELECT id FROM habit_categories WHERE name_en='Productivity'), 'Günlük Yaz', 'Journal', 'Günlük tut', 'edit_note', '#EC4899', 'daily', 1, NULL, true, 6),
  ((SELECT id FROM habit_categories WHERE name_en='Fitness'), 'Yürüyüş', 'Walk', 'Günlük yürüyüş yap', 'directions_walk', '#84CC16', 'daily', 5000, 'adım', true, 7),
  ((SELECT id FROM habit_categories WHERE name_en='Nutrition'), 'Sağlıklı Beslen', 'Eat Healthy', 'Sağlıklı öğünler ye', 'restaurant', '#14B8A6', 'daily', 3, 'öğün', true, 8),
  ((SELECT id FROM habit_categories WHERE name_en='Education'), 'Dil Öğren', 'Learn Language', 'Yabancı dil çalış', 'translate', '#6366F1', 'daily', 15, 'dakika', false, 9),
  ((SELECT id FROM habit_categories WHERE name_en='Social'), 'Aile ile Vakit Geçir', 'Family Time', 'Aileye zaman ayır', 'family_restroom', '#F43F5E', 'daily', 30, 'dakika', false, 10),
  ((SELECT id FROM habit_categories WHERE name_en='Finance'), 'Tasarruf Yap', 'Save Money', 'Günlük tasarruf hedefi', 'savings', '#10B981', 'daily', 1, NULL, false, 11),
  ((SELECT id FROM habit_categories WHERE name_en='Self Care'), 'Cilt Bakımı', 'Skincare', 'Günlük cilt bakım rutini', 'face_retouching_natural', '#F472B6', 'daily', 1, NULL, false, 12),
  ((SELECT id FROM habit_categories WHERE name_en='Creativity'), 'Çizim Yap', 'Draw', 'Her gün bir şey çiz', 'brush', '#FBBF24', 'daily', 15, 'dakika', false, 13),
  ((SELECT id FROM habit_categories WHERE name_en='Mental Health'), 'Dijital Detoks', 'Digital Detox', 'Ekransız zaman geçir', 'phone_disabled', '#A78BFA', 'daily', 60, 'dakika', false, 14),
  ((SELECT id FROM habit_categories WHERE name_en='Health'), 'Vitamin Al', 'Take Vitamins', 'Günlük vitamin ve takviye', 'medication', '#FB923C', 'daily', 1, NULL, false, 15);

-- ============================================================
-- 5. HABITS (Kullanıcı Alışkanlıkları)
-- ============================================================
CREATE TABLE public.habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  managed_profile_id UUID REFERENCES public.managed_profiles(id) ON DELETE SET NULL,
  preset_id UUID REFERENCES public.preset_habits(id),
  category_id UUID REFERENCES public.habit_categories(id),
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT NOT NULL DEFAULT 'check_circle',
  color TEXT NOT NULL DEFAULT '#3B82F6',
  
  -- Periyod ve hedef
  frequency TEXT NOT NULL DEFAULT 'daily',  -- daily, weekly, custom
  custom_days INT[] DEFAULT '{}',            -- 0=Pzt, 1=Sal, ... 6=Paz (custom için)
  target_count INT DEFAULT 1,
  unit TEXT,                                 -- bardak, dakika, sayfa, vs.
  
  -- Süre takibi
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date DATE,                             -- NULL = süresiz
  
  -- Hatırlatma
  reminder_enabled BOOLEAN DEFAULT false,
  reminder_time TIME,
  
  -- Durum
  is_active BOOLEAN DEFAULT true,
  is_archived BOOLEAN DEFAULT false,
  current_streak INT DEFAULT 0,
  best_streak INT DEFAULT 0,
  total_completions INT DEFAULT 0,
  
  -- Liderlik tablosu
  is_public BOOLEAN DEFAULT false,           -- Leaderboard'da görünsün mü?
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 6. HABIT ENTRIES (Günlük Alışkanlık Kayıtları)
-- ============================================================
CREATE TABLE public.habit_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  
  -- İlerleme
  value INT DEFAULT 0,         -- yapılan miktar
  target INT DEFAULT 1,        -- hedef miktar
  is_completed BOOLEAN DEFAULT false,
  
  -- Duygu ve not
  mood INT CHECK (mood >= 1 AND mood <= 5),   -- 1=çok kötü, 5=çok iyi
  note TEXT,
  
  -- Meta
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(habit_id, entry_date)
);

-- ============================================================
-- 7. FRIENDSHIPS (Arkadaşlıklar)
-- ============================================================
CREATE TABLE public.friendships (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  addressee_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'blocked')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(requester_id, addressee_id),
  CHECK (requester_id != addressee_id)
);

-- ============================================================
-- 8. FRIEND INVITES (Davet Kodları)
-- ============================================================
CREATE TABLE public.friend_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inviter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  invite_code TEXT NOT NULL UNIQUE,
  max_uses INT DEFAULT 1,
  used_count INT DEFAULT 0,
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '7 days'),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 9. CHALLENGES (Rekabet / Meydan Okumalar)
-- ============================================================
CREATE TABLE public.challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  preset_habit_id UUID REFERENCES public.preset_habits(id),
  name TEXT NOT NULL,
  description TEXT,
  habit_name TEXT NOT NULL,
  target_days INT NOT NULL DEFAULT 30,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.challenge_participants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  completed_days INT DEFAULT 0,
  current_streak INT DEFAULT 0,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(challenge_id, user_id)
);

-- ============================================================
-- 10. NOTIFICATIONS (Bildirimler)
-- ============================================================
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- habit_reminder, friend_request, challenge_invite, streak_warning, achievement
  title TEXT NOT NULL,
  body TEXT,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 11. ACHIEVEMENTS (Başarımlar)
-- ============================================================
CREATE TABLE public.achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name_tr TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_tr TEXT NOT NULL,
  description_en TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  condition_type TEXT NOT NULL, -- streak, total_completions, habits_count, xp_level
  condition_value INT NOT NULL,
  xp_reward INT DEFAULT 50
);

CREATE TABLE public.user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES public.achievements(id),
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, achievement_id)
);

-- Varsayılan başarımlar
INSERT INTO public.achievements (name_tr, name_en, description_tr, description_en, icon, color, condition_type, condition_value, xp_reward) VALUES
  ('İlk Adım', 'First Step', 'İlk alışkanlığını oluştur', 'Create your first habit', 'star', '#FFD700', 'habits_count', 1, 10),
  ('Üç Gün Seri', '3 Day Streak', '3 gün üst üste bir alışkanlığı tamamla', 'Complete a habit 3 days in a row', 'local_fire_department', '#FF6B35', 'streak', 3, 25),
  ('Haftalık Şampiyon', 'Weekly Champion', '7 gün üst üste seri yap', '7 day streak', 'emoji_events', '#C0C0C0', 'streak', 7, 50),
  ('Aylık Efsane', 'Monthly Legend', '30 gün üst üste seri yap', '30 day streak', 'military_tech', '#FFD700', 'streak', 30, 200),
  ('Yüz Tamamlama', 'Century', 'Toplam 100 alışkanlık tamamla', 'Complete 100 habits total', 'looks_one', '#8B5CF6', 'total_completions', 100, 100),
  ('Alışkanlık Ustası', 'Habit Master', '5 aktif alışkanlığın olsun', 'Have 5 active habits', 'workspace_premium', '#3B82F6', 'habits_count', 5, 75),
  ('Sosyal Kelebek', 'Social Butterfly', '3 arkadaş ekle', 'Add 3 friends', 'diversity_3', '#EC4899', 'habits_count', 3, 50);

-- ============================================================
-- 12. CHECK-IN PROMPTS (Durum Bilgisi İstemleri)
-- ============================================================
CREATE TABLE public.checkin_prompts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  prompt_tr TEXT NOT NULL,
  prompt_en TEXT NOT NULL,
  mood_related BOOLEAN DEFAULT false,
  time_of_day TEXT DEFAULT 'any' -- morning, afternoon, evening, any
);

INSERT INTO public.checkin_prompts (prompt_tr, prompt_en, mood_related, time_of_day) VALUES
  ('Bugün nasıl hissediyorsun?', 'How are you feeling today?', true, 'morning'),
  ('Bugünkü hedeflerine ulaştın mı?', 'Did you reach your goals today?', false, 'evening'),
  ('Enerjin nasıl?', 'How is your energy?', true, 'any'),
  ('Bugün kendine zaman ayırabildin mi?', 'Did you make time for yourself today?', false, 'evening'),
  ('Motivasyonun nasıl gidiyor?', 'How is your motivation going?', true, 'any'),
  ('Bu hafta en çok hangi alışkanlığınla gurur duydun?', 'Which habit are you most proud of this week?', false, 'any'),
  ('Hedeflerine yaklaştığını hissediyor musun?', 'Do you feel closer to your goals?', true, 'any'),
  ('Bugün neye minnet duyuyorsun?', 'What are you grateful for today?', true, 'morning');

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_habits_user ON public.habits(user_id);
CREATE INDEX idx_habits_active ON public.habits(user_id, is_active);
CREATE INDEX idx_habit_entries_habit ON public.habit_entries(habit_id, entry_date);
CREATE INDEX idx_habit_entries_user_date ON public.habit_entries(user_id, entry_date);
CREATE INDEX idx_friendships_users ON public.friendships(requester_id, addressee_id);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, is_read);
CREATE INDEX idx_challenge_participants ON public.challenge_participants(challenge_id, user_id);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.managed_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friend_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Profiles: Kendi profilini oku/güncelle, başkalarının public bilgisini oku
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Public profiles readable" ON public.profiles FOR SELECT USING (true);

-- Managed Profiles
CREATE POLICY "Owner can manage" ON public.managed_profiles FOR ALL USING (auth.uid() = owner_id);

-- Habits
CREATE POLICY "Users can CRUD own habits" ON public.habits FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Public habits readable" ON public.habits FOR SELECT USING (is_public = true);

-- Habit Entries
CREATE POLICY "Users can CRUD own entries" ON public.habit_entries FOR ALL USING (auth.uid() = user_id);

-- Friendships
CREATE POLICY "Users can view own friendships" ON public.friendships FOR SELECT 
  USING (auth.uid() = requester_id OR auth.uid() = addressee_id);
CREATE POLICY "Users can create friend requests" ON public.friendships FOR INSERT 
  WITH CHECK (auth.uid() = requester_id);
CREATE POLICY "Users can update own friendships" ON public.friendships FOR UPDATE 
  USING (auth.uid() = addressee_id OR auth.uid() = requester_id);

-- Friend Invites
CREATE POLICY "Users can manage own invites" ON public.friend_invites FOR ALL USING (auth.uid() = inviter_id);
CREATE POLICY "Anyone can read invites" ON public.friend_invites FOR SELECT USING (true);

-- Challenges
CREATE POLICY "Anyone can view public challenges" ON public.challenges FOR SELECT USING (is_public = true);
CREATE POLICY "Creator can manage" ON public.challenges FOR ALL USING (auth.uid() = creator_id);

-- Challenge Participants
CREATE POLICY "Participants can view" ON public.challenge_participants FOR SELECT USING (true);
CREATE POLICY "Users can join" ON public.challenge_participants FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Notifications
CREATE POLICY "Users can manage own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- User Achievements
CREATE POLICY "Users can view own achievements" ON public.user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can insert" ON public.user_achievements FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Kullanıcı'),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update streak on habit entry
CREATE OR REPLACE FUNCTION public.update_habit_streak()
RETURNS TRIGGER AS $$
DECLARE
  current_streak_val INT;
  best_streak_val INT;
BEGIN
  IF NEW.is_completed = true THEN
    -- Calculate current streak
    WITH consecutive AS (
      SELECT entry_date, 
             entry_date - (ROW_NUMBER() OVER (ORDER BY entry_date))::INT * INTERVAL '1 day' as grp
      FROM public.habit_entries 
      WHERE habit_id = NEW.habit_id AND is_completed = true
      ORDER BY entry_date DESC
    )
    SELECT COUNT(*) INTO current_streak_val
    FROM consecutive 
    WHERE grp = (SELECT grp FROM consecutive LIMIT 1);
    
    SELECT best_streak INTO best_streak_val FROM public.habits WHERE id = NEW.habit_id;
    
    UPDATE public.habits SET 
      current_streak = current_streak_val,
      best_streak = GREATEST(best_streak_val, current_streak_val),
      total_completions = total_completions + 1,
      updated_at = NOW()
    WHERE id = NEW.habit_id;
    
    -- Update profile stats
    UPDATE public.profiles SET
      total_completed = total_completed + 1,
      xp = xp + 10,
      streak_record = GREATEST(streak_record, current_streak_val),
      updated_at = NOW()
    WHERE id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_habit_entry_completed
  AFTER INSERT OR UPDATE ON public.habit_entries
  FOR EACH ROW EXECUTE FUNCTION public.update_habit_streak();

-- Updated at trigger
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON public.habits
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Leaderboard view
CREATE OR REPLACE VIEW public.leaderboard AS
SELECT 
  p.id as user_id,
  p.display_name,
  p.avatar_url,
  p.level,
  p.xp,
  p.streak_record,
  p.total_completed,
  RANK() OVER (ORDER BY p.xp DESC) as rank
FROM public.profiles p
WHERE p.total_completed > 0
ORDER BY p.xp DESC;

-- Habit-specific leaderboard function
CREATE OR REPLACE FUNCTION public.get_habit_leaderboard(habit_name_filter TEXT)
RETURNS TABLE (
  user_id UUID,
  display_name TEXT,
  avatar_url TEXT,
  total_completions INT,
  best_streak INT,
  rank BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    h.user_id,
    p.display_name,
    p.avatar_url,
    h.total_completions,
    h.best_streak,
    RANK() OVER (ORDER BY h.total_completions DESC, h.best_streak DESC) as rank
  FROM public.habits h
  JOIN public.profiles p ON p.id = h.user_id
  WHERE h.is_public = true 
    AND h.name ILIKE '%' || habit_name_filter || '%'
    AND h.is_active = true
  ORDER BY rank;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Generate invite code function
CREATE OR REPLACE FUNCTION public.generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..8 LOOP
    result := result || SUBSTR(chars, FLOOR(RANDOM() * LENGTH(chars) + 1)::INT, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

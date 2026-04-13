-- ============================================================
-- Seed Notebook Sections (Demo Kullanıcı İçin)
-- ============================================================
-- Bu betik, demo profil (Bilal) için örnek notebook bölümleri oluşturur
-- Kullanıcı profili ID'sini profiles tablosundan alarak çalıştırın

-- Demo kullanıcı ID'yi almak için (email = 'demo@solstice.app' veya display_name = 'Bilal')
-- SELECT id FROM public.profiles WHERE display_name = 'Bilal' LIMIT 1;

-- Örnek bölümler eklemek için (user_id'yi gerçek ID ile değiştirin):
/*
INSERT INTO public.notebook_sections (user_id, name, icon, color, sort_order) VALUES
  ('USER_ID_HERE', 'Genel', 'notes', '#3B82F6', 1),
  ('USER_ID_HERE', 'Fitness', 'fitness_center', '#EF4444', 2),
  ('USER_ID_HERE', 'Beslenme', 'restaurant', '#84CC16', 3),
  ('USER_ID_HERE', 'Kitaplar', 'menu_book', '#8B5CF6', 4),
  ('USER_ID_HERE', 'Hedefler', 'flag', '#F97316', 5),
  ('USER_ID_HERE', 'Alışveriş', 'shopping_cart', '#EC4899', 6);
*/

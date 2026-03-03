# 🎯 Habitra - Alışkanlık Takip Uygulaması

**Habitra**, günlük alışkanlıklarını takip etmeni, arkadaşlarınla yarışmanı ve oyunlaştırma ile motivasyonunu yüksek tutmanı sağlayan bir mobil uygulamadır.

## ✨ Özellikler

- **Alışkanlık Takibi** — Özel veya hazır şablonlardan alışkanlık oluştur, günlük ilerlemeni kaydet
- **Takvim Görünümü** — Geçmiş kayıtlarını takvim üzerinden incele
- **Oyunlaştırma** — XP kazan, seviye atla, seri yakala, rozetler aç
- **Sosyal Özellikler** — Arkadaşlarını davet et, birlikte yarış
- **Liderlik Tablosu** — Global XP sıralamasında yerini gör
- **Çoklu Profil** — Aile üyelerini takip et (çocuk, eş, ebeveyn)
- **Check-in Sistemi** — Motivasyon artırıcı rastgele hatırlatmalar
- **Karanlık/Aydınlık Tema** — Material 3 tasarım dili

## 🛠️ Teknolojiler

| Katman | Teknoloji |
|--------|-----------|
| Frontend | Flutter (Dart) |
| Backend | Supabase (PostgreSQL) |
| State Management | Riverpod |
| Routing | go_router |
| Auth | Google Sign-In + Supabase Auth |
| UI | Material 3, Poppins Font, fl_chart |

## 📁 Proje Yapısı

```
lib/
├── main.dart
├── core/
│   ├── constants/      # Supabase, uygulama, renk sabitleri
│   ├── theme/          # Aydınlık/karanlık tema
│   ├── services/       # Supabase, auth, habit, profile, friend servisleri
│   ├── router/         # go_router yapılandırması
│   └── utils/          # Yardımcı fonksiyonlar
├── features/
│   ├── auth/           # Giriş ekranı (Google OAuth)
│   ├── home/           # Ana sayfa, alışkanlık kartları, haftalık grafik
│   ├── habits/         # Alışkanlık ekleme ve detay
│   ├── calendar/       # Takvim görünümü
│   ├── profile/        # Profil ve ayarlar
│   ├── leaderboard/    # Liderlik tablosu
│   └── friends/        # Arkadaş listesi ve davetler
└── shared/             # Ortak modeller ve widget'lar
```

## 🚀 Kurulum

### 1. Supabase Projesi Oluştur
- [supabase.com](https://supabase.com) üzerinde yeni proje oluştur
- SQL Editor'da `supabase/schema.sql` dosyasını çalıştır
- Authentication > Providers > Google'ı aktif et

### 2. Yapılandırma
`lib/core/constants/supabase_constants.dart` dosyasını düzenle:
```dart
class SupabaseConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Google Sign-In Ayarları

**Android:**
- Firebase Console'dan SHA-1 fingerprint ekle
- `google-services.json` dosyasını `android/app/` altına koy

**iOS:**
- `ios/Runner/Info.plist` dosyasına Google URL scheme ekle

### 4. Çalıştır
```bash
flutter pub get
flutter run
```

## 🎮 Oyunlaştırma Sistemi

| Seviye | Unvan | Gereken XP |
|--------|-------|------------|
| 1-4 | Çaylak | 0-400 |
| 5-9 | Alışkan | 500-900 |
| 10-19 | Kararlı | 1000-1900 |
| 20-29 | Uzman | 2000-2900 |
| 30-49 | Usta | 3000-4900 |
| 50+ | Efsane | 5000+ |

Her alışkanlık tamamlama **10 XP** kazandırır.

## 📄 Lisans
Bu proje MIT lisansı altında sunulmaktadır.

---
**Habitra** ile alışkanlıklarını güçlendir! 💪

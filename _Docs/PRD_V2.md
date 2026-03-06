# Habitra v2.0 — Ürün Gereksinim Dokümanı (PRD)
**Vizyon:** Fiziksel ajandadan çok daha fazlası — insanların eli ayağı olan, kişiselleştirilebilir, cıvıl cıvıl bir dijital yaşam asistanı.

---

## 1. Tema & Görsel Kimlik

### 1.1 Yeni Renk Paleti — "Turuncu Enerji"
Renk teorisi: Turuncu = enerji, motivasyon, sıcaklık, yaratıcılık, coşku.

| Token | Eski Hex | Yeni Hex | Açıklama |
|-------|----------|----------|----------|
| primary | `#6C63FF` | `#FF6B2C` | Canlı turuncu — ana CTA, FAB, seçili öğe |
| primaryLight | `#9D97FF` | `#FF9A6C` | Açık turuncu — hover, gradient bitiş |
| primaryDark | `#4A42D4` | `#E05A1B` | Koyu turuncu — gradient başlangıç, pressed |
| accent | `#FF6B6B` | `#FFD93D` | Sarı — dikkat çekici, ödül, kutlama |
| accentLight | `#FF9B9B` | `#FFE88D` | Açık sarı — dark mode accent |
| success | `#4CAF50` | `#4CAF50` | Aynı kalır (yeşil) |
| background (light) | `#F8F9FE` | `#FFF8F3` | Krem-sıcak beyaz |
| surface (light) | `#FFFFFF` | `#FFFFFF` | Beyaz |
| surfaceVariant | `#F0F0F8` | `#FFF0E6` | Açık turuncu ton |
| darkBackground | `#0F0F1A` | `#1A1209` | Sıcak koyu |
| darkSurface | `#1A1A2E` | `#2A1F14` | Sıcak koyu yüzey |

### 1.2 Gradient'ler
- **Login:** `#FF6B2C → #E05A1B → #C44A10`
- **Header:** `#FF6B2C → #FF9A6C`
- **Ödül/Kutlama:** `#FFD93D → #FF6B2C` (sarıdan turuncuya)
- **Streak Ateşi:** `#FF4500 → #FF6B2C → #FFD93D`

### 1.3 Sticker & Kişiselleştirme
- Kullanıcılar hedeflerine ulaştığında dijital sticker kazanır
- Sticker'lar profil, not defteri ve takvime yapıştırılabilir
- Tema mağazası: streak'le açılan temalar (30 gün = yeni tema)
- Alışkanlık kartları özelleştirilebilir (renk, ikon, sticker)

---

## 2. Yeni Modüller

### 2.1 📝 Not Defteri (Notebook)
**Konsept:** Fiziksel bir defterin dijital versiyonu. Sağ tarafta renkli fihrist tabları.

**Bölümler (varsayılan, kullanıcı ekleyebilir/sıralayabilir):**

| Bölüm | Fihrist Rengi | İçerik |
|-------|---------------|--------|
| 📋 Günlük | `#FF6B2C` turuncu | Günlük not, düşünce, günlük soruları |
| 🏋️ Spor Programı | `#4CAF50` yeşil | Antrenman planı, setler, tekrarlar (offline) |
| 🥗 Diyet Listesi | `#8BC34A` açık yeşil | Öğün planı, kalori, su takibi (offline) |
| 🛒 Alışveriş | `#2196F3` mavi | Alınacaklar listesi (checklist) |
| 📖 Okuma Listesi | `#9C27B0` mor | Kitaplar, sayfalar, notlar |
| 🎯 Hedefler | `#FF9800` turuncu | Yıllık/aylık hedefler |
| 📌 Genel Notlar | `#607D8B` gri | Serbest not alanı |

**Fihrist UI:**
- Sağ kenarda dikey şerit (ince çizgi, ~30px genişlik)
- Her bölüm farklı renkte bir tab
- Tıkla → o bölüme atla
- Drag & drop ile sıralama
- Tüm notlar offline erişilebilir (local SQLite cache)

**Not Tipi Seçenekleri:**
- Serbest metin (zengin editör)
- Checklist (alışveriş, yapılacaklar)
- Tablo (spor seti, diyet planı)
- Etiketli not (kategorize)

---

### 2.2 📅 Takvim & Hatırlatıcılar
**Konsept:** Google Calendar benzeri ama alışkanlıklarla entegre.

**Etkinlik Türleri:**

| Tür | İkon | Renk | Hatırlatma |
|-----|------|------|------------|
| Toplantı | 🤝 | Mavi | 15dk/1sa önce |
| Doktor Randevusu | 🏥 | Kırmızı | 1 gün + 1sa önce |
| Date / Sosyal | ❤️ | Pembe | 2sa önce |
| İlaç / Vitamin | 💊 | Yeşil | Belirlenen saatte (tekrarlı) |
| Su Hatırlatıcı | 💧 | Açık mavi | Her X saatte bir |
| Uyku / Uyanma | ⏰ | Mor | Sabah alarm |
| Genel Hatırlatma | 🔔 | Turuncu | Özel |

**Özellikler:**
- Günlük/haftalık/aylık görünüm
- Tekrarlayan etkinlikler (ilaç: her gün 08:00, 20:00)
- Push notification entegrasyonu
- Google Calendar sync (opsiyonel, gelecek faz)
- Sağ tarafta "bugünün hatırlatmaları" panel

---

### 2.3 🎯 Hedef Sistemi
**Konsept:** Yıllık → Aylık → Haftalık kırılımlı hedef yönetimi.

**Hedef Yapısı:**
```
Yıllık Hedef: "50 kitap oku"
  ├── Aylık Hedef: "5 kitap oku" (Ocak)
  │     ├── Haftalık: "1-2 kitap"
  │     └── İlerleme: 3/5 (%60)
  ├── Aylık Hedef: "4 kitap oku" (Şubat)
  └── Toplam İlerleme: 12/50 (%24)
```

**Kategoriler:**
- 🏋️ Sağlık & Fitness
- 📖 Kişisel Gelişim
- 💰 Finansal
- 🎓 Eğitim & Kariyer
- 🧘 Zihinsel Sağlık
- 🎨 Hobi & Yaratıcılık
- 👥 Sosyal & İlişkiler

**Hedef tamamlandığında:**
- Kutlama animasyonu (konfeti + sticker)
- XP ödülü
- Başarım rozeti

---

### 2.4 🔥 Streak Ödül Sistemi
**Konsept:** Zincirleri kırmadan devam edenlere kademeli ödüller.

| Streak | Ödül | Tür |
|--------|------|-----|
| 🔥 3 gün | "Başlangıç" rozeti | Rozet |
| 🔥 7 gün | "Kararlı" rozeti + sticker paketi | Rozet + Sticker |
| 🔥 14 gün | Özel alışkanlık ikonu seti | Kişiselleştirme |
| 🔥 30 gün | Yeni tema açılır (ilk tema ödülü) | Tema |
| 🔥 60 gün | "Demir İrade" rozeti + animasyonlu profil çerçevesi | Rozet + Profil |
| 🔥 100 gün | "Efsane" özel başarı + altın sticker paketi | Başarım + Sticker |
| 🔥 180 gün | Premium tema paketi | Tema Paketi |
| 🔥 365 gün | "Yıldönümü" özel rozet + tüm temalar | Her Şey |

**Ödül Çeşitleri:**
- **Rozetler:** Profilde sergilenebilir, arkadaşlar görebilir
- **Sticker'lar:** Not defteri ve takvime yapıştırılabilir
- **Temalar:** Uygulama renk şeması değişir
- **Profil Çerçeveleri:** Avatar etrafında animasyonlu çerçeve
- **İkon Paketleri:** Alışkanlıklar için özel ikonlar

---

### 2.5 💭 Rehberli Günlük Soruları
**Konsept:** Her gün düşündürücü bir soru ile kullanıcıyı kişisel gelişime yönlendirme.

**Soru Kategorileri:**

| Kategori | Örnek Sorular |
|----------|---------------|
| Öz-Farkındalık | "Bugün seni en çok ne zorladı?", "Kendini en güçlü hissettiğin an hangisiydi?" |
| Hedef Odaklı | "Bu hafta en önemli 3 hedefin ne?", "Hayatında değiştirmek istediğin şey ne?" |
| Minnettarlık | "Bugün neye minnettar hissettin?", "Seni mutlu eden küçük bir an?" |
| Motivasyon | "1 yıl sonra kendini nerede görüyorsun?", "Bugün cesaret ettiğin bir şey ne?" |
| İlişkiler | "Bu hafta kiminle vakit geçirmek isterdin?", "Birine teşekkür etmen gereken biri var mı?" |
| Alışkanlık | "Hangi alışkanlığın seni en çok geliştiriyor?", "Bırakmak istediğin bir alışkanlık var mı?" |

**Akış:**
- Sabah check-in: günün sorusu gösterilir
- Kullanıcı kısa cevap yazar (günlüğe kaydedilir)
- Akşam check-in: "Bugün nasıl geçti?" + mood
- Haftalık özet: yazılan cevapların derlemesi
- Tüm cevaplar "Günlük" bölümünde kronolojik görüntülenebilir

---

### 2.6 💧 Su & İlaç Hatırlatıcı
**Konsept:** Gün boyunca düzenli aralıklarla hatırlatma.

**Su Takibi:**
- Günlük hedef: varsayılan 8 bardak (özelleştirilebilir)
- Her X saatte bir push bildirim
- Hızlı "+1 bardak" butonu (ana ekrandan erişilebilir)
- Günlük progress ring
- Haftalık/aylık su tüketim grafiği

**İlaç/Vitamin Hatırlatıcı:**
- İlaç adı, doz, saat, tekrar günleri
- Çoklu ilaç desteği
- "Aldım" / "Atladım" butonları
- İlaç stoku takibi (opsiyonel)
- Kaçırılan dozlar kırmızı uyarı

**Uyku/Uyanma:**
- "Kaçta uyandın?" sabah sorusu
- Uyku süresi hesaplama
- Haftalık uyku düzeni grafiği
- İdeal uyku saati hedefi

---

## 3. UI Yenilikler

### 3.1 Ana Ekran Yeniden Tasarım
```
┌──────────────────────────────────┐
│  🟠 Günaydın! 👋                │  ← Turuncu gradient header
│  "Motivasyon sözü"              │
│  [💧 5/8] [🔥 14] [⭐ 240 XP]  │  ← Quick stats
├──────────────────────────────────┤
│  💭 Günün Sorusu:               │  ← Kart: sarı-turuncu gradient
│  "Bugün seni en çok ne zorladı?"│
│  [Cevapla →]                    │
├──────────────────────────────────┤
│  📊 Haftalık Özet               │  ← Bar chart
│  ▓▓▓▓░░░                        │
├──────────────────────────────────┤
│  ⏰ Bugünün Hatırlatmaları      │  ← Sağ tarafta mini panel
│  09:00 💊 Vitamin D             │
│  14:00 🤝 Toplantı              │
│  20:00 💊 Omega-3               │
├──────────────────────────────────┤
│  Bugünkü Alışkanlıklar (5)     │
│  [Habit Card 1]                 │
│  [Habit Card 2]                 │
│  ...                            │
└──────────────────────────────────┘
```

### 3.2 Not Defteri Ekranı
```
┌──────────────────────────┬──┐
│                          │📋│ ← Renkli fihrist tabları
│  [Not içeriği]           │🏋│    (sağ kenarda dikey şerit)
│                          │🥗│
│  Spor Programım         │🛒│
│  ─────────────────       │📖│
│  Pazartesi:              │🎯│
│  • Bench Press 4x12      │📌│
│  • Squat 4x10            │  │
│  • Deadlift 3x8          │  │
│                          │  │
│  [+ Not Ekle]            │  │
└──────────────────────────┴──┘
```

### 3.3 Bottom Navigation (Güncelleme)
```
[🏠 Ana] [📝 Defter] [➕ FAB] [📅 Takvim] [👤 Profil]
```
- Önceki "Sıralama" tabı → Profil içine taşınır
- Yeni "Defter" (Not Defteri) tabı eklenir

---

## 4. Veritabanı Yeni Tabloları

### 4.1 Not Defteri
```sql
notebook_sections    — Bölüm tanımları (fihrist)
notebook_entries     — Not kayıtları (offline cache + sync)
```

### 4.2 Takvim & Hatırlatmalar
```sql
calendar_events      — Etkinlikler (toplantı, randevu, date vb.)
reminders            — Tekrarlayan hatırlatmalar (ilaç, su, uyku)
reminder_logs        — Hatırlatma geçmişi (aldım/atladım)
```

### 4.3 Hedefler
```sql
goals                — Ana hedefler (yıllık/aylık/haftalık)
goal_milestones      — Hedef kırılımları
```

### 4.4 Ödül Sistemi
```sql
streak_rewards       — Ödül tanımları (7,30,100 gün)
user_rewards         — Kazanılmış ödüller
stickers             — Sticker tanımları
user_stickers        — Kullanıcının sticker'ları
themes               — Tema tanımları
user_themes          — Açılmış temalar
```

### 4.5 Günlük Soruları
```sql
daily_questions      — Soru havuzu (kategori, tr, en)
daily_question_answers — Kullanıcı cevapları
```

### 4.6 Su & İlaç
```sql
water_logs           — Su tüketim kayıtları
medications          — İlaç/vitamin tanımları
medication_logs      — İlaç alma kayıtları
sleep_logs           — Uyku/uyanma kayıtları
```

---

## 5. Uygulama Fazları

### Faz 1 — Temel Dönüşüm (Öncelik: YÜKSEK)
- [x] Turuncu tema uygulaması
- [ ] Streak ödül sistemi (DB + UI)
- [ ] Günlük soruları modülü
- [ ] Su hatırlatıcı (basit versiyon)

### Faz 2 — Not Defteri (Öncelik: YÜKSEK)
- [ ] Not defteri bölüm yapısı + fihrist UI
- [ ] Serbest metin + checklist notlar
- [ ] Spor programı şablonu
- [ ] Diyet listesi şablonu
- [ ] Offline erişim (local cache)

### Faz 3 — Takvim & Hatırlatmalar (Öncelik: YÜKSEK)
- [ ] Takvim etkinlik sistemi
- [ ] İlaç/vitamin hatırlatıcı
- [ ] Uyku takibi
- [ ] Push notification entegrasyonu
- [ ] Tekrarlayan etkinlikler

### Faz 4 — Hedef Sistemi (Öncelik: ORTA)
- [ ] Yıllık/aylık/haftalık hedef yapısı
- [ ] Hedef ilerleme takibi
- [ ] Hedef tamamlama kutlamaları

### Faz 5 — Kişiselleştirme (Öncelik: ORTA)
- [ ] Sticker sistemi
- [ ] Tema mağazası
- [ ] Profil çerçeveleri
- [ ] Özel ikon paketleri
- [ ] Defter kapağı kişiselleştirme

### Faz 6 — Entegrasyonlar (Öncelik: DÜŞÜK)
- [ ] Google Calendar sync
- [ ] Widget (Android/iOS)
- [ ] Apple Health / Google Fit entegrasyonu
- [ ] Dışa aktarma (PDF günlük, CSV veriler)

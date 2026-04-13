"""
Solstice — Test Hesap Seed Scripti
3 hesap oluşturur: az, orta, çok kullanımlı
"""

import requests
import json
import random
from datetime import date, timedelta, datetime

# ─── Supabase Config ─────────────────────────────────────────────────────────
SUPABASE_URL = "https://jbpokrgowwpapmirgigl.supabase.co"
ANON_KEY     = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpicG9rcmdvd3dwYXBtaXJnaWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2MTg3NDMsImV4cCI6MjA4ODE5NDc0M30.dc_97RIB0DikQuld_b99mprY3aAfo64fjm5of6ReBPY"
SERVICE_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpicG9rcmdvd3dwYXBtaXJnaWdsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjYxODc0MywiZXhwIjoyMDg4MTk0NzQzfQ.23EFo3vJ6XaaQNxV4Kk7p-84Nv01uatySvFs1DxTWzE"

AUTH_URL  = f"{SUPABASE_URL}/auth/v1"
REST_URL  = f"{SUPABASE_URL}/rest/v1"

anon_headers = {
    "apikey": ANON_KEY,
    "Content-Type": "application/json",
}

svc_headers = {
    "apikey": SERVICE_KEY,
    "Authorization": f"Bearer {SERVICE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation",
}

# ─── Test Hesapları ───────────────────────────────────────────────────────────
ACCOUNTS = [
    {
        "email":    "test_az@solstice.app",
        "password": "Test1234!",
        "name":     "Ali Az",
        "level":    "az",
        "bio":      "Yeni başlıyorum 🌱",
        "days":     14,        # kaç gün geriye gidilsin
        "habits_count": 2,
        "completion_rate": 0.4, # %40 tamamlama
    },
    {
        "email":    "test_orta@solstice.app",
        "password": "Test1234!",
        "name":     "Merve Orta",
        "level":    "orta",
        "bio":      "Alışkanlık kurmaya çalışıyorum 💪",
        "days":     45,
        "habits_count": 5,
        "completion_rate": 0.72,
    },
    {
        "email":    "test_cok@solstice.app",
        "password": "Test1234!",
        "name":     "Kemal Çok",
        "level":    "cok",
        "bio":      "Disiplin özgürlüktür. 90+ gün seri! 🔥",
        "days":     120,
        "habits_count": 9,
        "completion_rate": 0.91,
    },
]

# ─── Habit şablonları ─────────────────────────────────────────────────────────
HABIT_TEMPLATES = [
    {"name": "Su İç",          "icon": "water_drop",         "color": "#3B82F6", "target_count": 8,  "unit": "bardak"},
    {"name": "Egzersiz Yap",   "icon": "fitness_center",     "color": "#EF4444", "target_count": 30, "unit": "dakika"},
    {"name": "Kitap Oku",      "icon": "menu_book",          "color": "#8B5CF6", "target_count": 20, "unit": "sayfa"},
    {"name": "Meditasyon",     "icon": "self_improvement",   "color": "#10B981", "target_count": 10, "unit": "dakika"},
    {"name": "Erken Kalk",     "icon": "alarm",              "color": "#F97316", "target_count": 1,  "unit": None},
    {"name": "Günlük Yaz",     "icon": "edit_note",          "color": "#EC4899", "target_count": 1,  "unit": None},
    {"name": "Yürüyüş",        "icon": "directions_walk",    "color": "#84CC16", "target_count": 5000, "unit": "adım"},
    {"name": "Vitamin Al",     "icon": "medication",         "color": "#FB923C", "target_count": 1,  "unit": None},
    {"name": "Dil Öğren",      "icon": "translate",          "color": "#6366F1", "target_count": 15, "unit": "dakika"},
]

# ─── Yardımcı fonksiyonlar ────────────────────────────────────────────────────

def signup(email, password, name):
    """Yeni kullanıcı kaydı oluştur"""
    r = requests.post(
        f"{AUTH_URL}/signup",
        headers=anon_headers,
        json={"email": email, "password": password, "data": {"full_name": name}},
    )
    data = r.json()
    if "error" in data or r.status_code not in (200, 201):
        print(f"  ⚠️  Kayıt hatası ({email}): {data.get('error_description') or data.get('msg') or data}")
        return None
    user_id = data.get("user", {}).get("id") or data.get("id")
    print(f"  ✅ Kullanıcı oluşturuldu: {email} → {user_id}")
    return user_id


def get_user_id_by_email(email):
    """Service role ile email'e göre user ID bul"""
    r = requests.get(
        f"{SUPABASE_URL}/auth/v1/admin/users?email={email}",
        headers={**svc_headers, "Authorization": f"Bearer {SERVICE_KEY}"},
    )
    users = r.json().get("users", [])
    if users:
        return users[0]["id"]
    return None


def upsert_profile(user_id, name, bio, level_label):
    """Profili güncelle (trigger otomatik oluşturur, biz bio/level ekleriz)"""
    xp_map   = {"az": 45,  "orta": 780,  "cok": 3200}
    lvl_map  = {"az": 1,   "orta": 7,    "cok": 32}
    streak_map = {"az": 4, "orta": 18,   "cok": 94}
    total_map  = {"az": 11,"orta": 210,  "cok": 980}

    r = requests.patch(
        f"{REST_URL}/profiles?id=eq.{user_id}",
        headers=svc_headers,
        json={
            "display_name": name,
            "bio": bio,
            "xp": xp_map[level_label],
            "level": lvl_map[level_label],
            "streak_record": streak_map[level_label],
            "total_completed": total_map[level_label],
        },
    )
    if r.status_code in (200, 204):
        print(f"  ✅ Profil güncellendi")
    else:
        print(f"  ⚠️  Profil güncelleme hatası: {r.text}")


def create_habits(user_id, count, start_date):
    """Alışkanlıklar oluştur"""
    templates = random.sample(HABIT_TEMPLATES, min(count, len(HABIT_TEMPLATES)))
    habit_ids = []
    for t in templates:
        r = requests.post(
            f"{REST_URL}/habits",
            headers=svc_headers,
            json={
                "user_id":       user_id,
                "name":          t["name"],
                "icon":          t["icon"],
                "color":         t["color"],
                "frequency":     "daily",
                "target_count":  t["target_count"],
                "unit":          t["unit"],
                "start_date":    start_date.isoformat(),
                "is_active":     True,
                "is_public":     True,
            },
        )
        if r.status_code in (200, 201):
            habit_ids.append(r.json()[0]["id"])
            print(f"    🏃 Alışkanlık: {t['name']}")
        else:
            print(f"    ⚠️  Alışkanlık hatası: {r.text[:100]}")
    return habit_ids


def create_entries(user_id, habit_ids, days, completion_rate):
    """Geçmiş günler için habit_entries oluştur"""
    today = date.today()
    entries = []
    for habit_id in habit_ids:
        for i in range(days, 0, -1):
            entry_date = today - timedelta(days=i)
            completed  = random.random() < completion_rate
            value      = random.randint(1, 3) if not completed else random.randint(3, 5)
            target     = 1
            entries.append({
                "habit_id":     habit_id,
                "user_id":      user_id,
                "entry_date":   entry_date.isoformat(),
                "value":        value,
                "target":       target,
                "is_completed": completed,
                "mood":         random.randint(2, 5) if completed else random.randint(1, 3),
                "completed_at": datetime.combine(entry_date, datetime.min.time()).isoformat() if completed else None,
            })

    # Batch insert (100'erli)
    total = 0
    for i in range(0, len(entries), 100):
        batch = entries[i:i+100]
        r = requests.post(
            f"{REST_URL}/habit_entries",
            headers={**svc_headers, "Prefer": "resolution=merge-duplicates,return=minimal"},
            json=batch,
        )
        if r.status_code in (200, 201, 204):
            total += len(batch)
        else:
            print(f"    ⚠️  Entry batch hatası: {r.text[:150]}")

    print(f"    📅 {total} giriş eklendi ({days} gün × {len(habit_ids)} alışkanlık)")


def create_notebook_entries(user_id, level_label):
    """Not defteri girişleri ekle (notebook_sections + notebook_entries)"""
    entries_map = {
        "az":   [("Hedeflerim", "#FF6B2C", "edit_note", ["Su içmeye başladım 💧", "Daha iyi olacak!"])],
        "orta": [
            ("Günlük",  "#FF6B2C", "edit_note",   ["Bugün meditasyon yaptım 🧘", "Egzersiz hedefimi tutturdum!", "Kitabı bitirdim ✅"]),
            ("Hedefler","#FF9800", "flag",         ["Bu ay 5kg vermek istiyorum", "Her gün 8 bardak su"]),
        ],
        "cok":  [
            ("Günlük",  "#FF6B2C", "edit_note",   [f"Gün {i+1}: Harika bir gün! 🔥" for i in range(10)]),
            ("Spor",    "#4CAF50", "fitness_center",["Bugün 10km koştum", "Ağırlık antrenmanı tamamlandı", "Yeni rekor: 100 squat"]),
            ("Hedefler","#FF9800", "flag",         ["Q2 hedefleri: daily streak 100 gün", "5 kitap okumak", "Marathon hazırlığı"]),
            ("Okuma",   "#9C27B0", "menu_book",    ["Atomik Alışkanlıklar - notlar", "Deep Work tamamlandı", "Bir sonraki: The Obstacle Is The Way"]),
        ],
    }
    sections = entries_map.get(level_label, [])
    for section_name, color, icon, notes in sections:
        # Bölüm oluştur
        r = requests.post(
            f"{REST_URL}/notebook_sections",
            headers=svc_headers,
            json={"user_id": user_id, "title": section_name, "color": color, "icon": icon, "sort_order": 0},
        )
        if r.status_code not in (200, 201):
            # Tablo yoksa sessizce geç
            return
        section_id = r.json()[0]["id"]
        for i, note in enumerate(notes):
            entry_date = (date.today() - timedelta(days=len(notes) - i)).isoformat()
            requests.post(
                f"{REST_URL}/notebook_entries",
                headers=svc_headers,
                json={"section_id": section_id, "user_id": user_id, "content": note, "created_at": f"{entry_date}T10:00:00Z"},
            )
        print(f"    📓 Not bölümü: {section_name} ({len(notes)} giriş)")


# ─── Ana akış ─────────────────────────────────────────────────────────────────

def seed_account(account):
    print(f"\n{'='*55}")
    print(f"👤 {account['name']} ({account['level'].upper()}) — {account['email']}")
    print(f"{'='*55}")

    # 1. Hesap oluştur (varsa atla)
    user_id = signup(account["email"], account["password"], account["name"])
    if not user_id:
        user_id = get_user_id_by_email(account["email"])
        if user_id:
            print(f"  ℹ️  Mevcut hesap kullanılıyor: {user_id}")
        else:
            print(f"  ❌ Kullanıcı ID alınamadı, atlanıyor.")
            return

    # 2. Profil güncelle
    upsert_profile(user_id, account["name"], account["bio"], account["level"])

    # 3. Alışkanlıklar oluştur
    start_date = date.today() - timedelta(days=account["days"])
    print(f"  🏃 {account['habits_count']} alışkanlık oluşturuluyor...")
    habit_ids = create_habits(user_id, account["habits_count"], start_date)

    # 4. Geçmiş girişler ekle
    if habit_ids:
        print(f"  📅 {account['days']} günlük geçmiş ekleniyor (%{int(account['completion_rate']*100)} tamamlama)...")
        create_entries(user_id, habit_ids, account["days"], account["completion_rate"])

    # 5. Not defteri
    print(f"  📓 Not defteri girişleri ekleniyor...")
    create_notebook_entries(user_id, account["level"])

    print(f"  ✅ TAMAMLANDI → {account['email']} / {account['password']}")


if __name__ == "__main__":
    print("🌱 Solstice Test Hesap Seed Scripti Başladı\n")
    for acc in ACCOUNTS:
        seed_account(acc)

    print(f"\n{'='*55}")
    print("🎉 TÜM HESAPLAR HAZIR!")
    print(f"{'='*55}")
    print("\n📋 Giriş Bilgileri:")
    for acc in ACCOUNTS:
        label = {"az": "🟡 Az    ", "orta": "🟠 Orta  ", "cok": "🔴 Çok   "}[acc["level"]]
        print(f"  {label} {acc['email']}  /  {acc['password']}")

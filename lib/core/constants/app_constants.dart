class AppConstants {
  static const String appName = 'Solstice';
  static const String appVersion = '1.0.0';

  // Gamification
  static const int xpPerCompletion = 10;
  static const int xpPerLevel = 100;
  static const int maxActiveHabits = 20;
  static const int maxManagedProfiles = 5;

  // Mood
  static const List<String> moodEmojis = ['😞', '😕', '😐', '🙂', '😄'];
  static const List<String> moodLabels = ['Çok Kötü', 'Kötü', 'Normal', 'İyi', 'Harika'];

  // Motivational quotes
  static const List<String> quotes = [
    'Her uzun yolculuk tek bir adımla başlar.',
    'Bugün yaptıkların, yarınını şekillendirir.',
    'Küçük adımlar, büyük değişimler yaratır.',
    'Tutarlılık, başarının anahtarıdır.',
    'Kendine inan, yapabilirsin!',
    'Alışkanlıkların kaderini belirler.',
    'Bugün en iyi versiyonun ol.',
    'Her yeni gün, yeni bir başlangıç.',
    'Disiplin, özgürlüğe giden yoldur.',
  ];

  // Günün Sorusu — her gün farklı bir soru (yılın gününe göre döner)
  static const List<String> dailyQuestions = [
    'Bugün kendini nasıl hissediyorsun?',
    'Bu hafta en çok neye minnettar olduğun şey ne?',
    'Hayatında değiştirmek istediğin bir alışkanlık var mı?',
    'Bugün seni mutlu eden küçük bir an oldu mu?',
    'Gelecek ay için en büyük hedefin ne?',
    'En son ne zaman kendin için vakit ayırdın?',
    'Bugün biri için güzel bir şey yaptın mı?',
    'Şu an hayatındaki en büyük öncelik ne?',
    'Kendine hangi konuda daha sabırlı olmalısın?',
    'Bu yıl öğrendiğin en değerli ders ne?',
    'Hayatından çıkarmak istediğin bir şey var mı?',
    'En son ne zaman konfor alanından çıktın?',
    'Bugün hangi alışkanlığını güçlendirmek istiyorsun?',
    'Seni en çok motive eden şey ne?',
    'Yarın daha iyi bir gün olması için ne yapabilirsin?',
    'Hayatındaki en önemli üç kişi kim?',
    'Kendine yeterince su içiyor musun?',
    'Bu hafta okuduğun/izlediğin en ilham verici şey ne?',
    'Zihnini meşgul eden bir konu var mı?',
    'Fiziksel sağlığın için bugün ne yaptın?',
    'En son ne zaman doğada vakit geçirdin?',
    'Ruh sağlığın için bugün ne yapabilirsin?',
    'Bugün hangi başarını kutlayabilirsin?',
    'Hayatını kolaylaştıracak küçük bir değişiklik ne olurdu?',
    'En son ne zaman yeni bir şey denedin?',
    'Bugün kiminle iletişim kurmalısın?',
    'Uyku düzenin nasıl? İyileştirebilir misin?',
    'Bugün ne öğrendin?',
    'Kendine karşı daha nazik olabilir misin?',
    'Gelecekteki sen bugünkü senden ne isterdi?',
    'Bugün neyi farklı yapabilirdin?',
  ];

  /// Bugünün sorusunu döndürür (yılın gününe göre)
  static String get todayQuestion {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return dailyQuestions[dayOfYear % dailyQuestions.length];
  }
}

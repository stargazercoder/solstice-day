import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/constants/supabase_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Web'de Chrome DevTools & otomasyon araclari icin semantics aktif et
  // → aria-label, role gibi ozellikler DOM'da gorunur olur
  // → Elements panelinde flt-semantics elementleri inspect edilebilir
  // → document.querySelectorAll('[role]') ile Console'dan erisim
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(const ProviderScope(child: SolsticeApp()));
}

class SolsticeApp extends ConsumerWidget {
  const SolsticeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    final themeSettings = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Solstice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeSettings.themeMode,
      routerConfig: router,
      locale: const Locale('tr', 'TR'),
    );
  }
}

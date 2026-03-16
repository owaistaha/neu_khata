import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'models/business_profile.dart';
import 'models/customer.dart';
import 'models/reminder.dart';
import 'models/transaction.dart' as tx;
import 'providers/app_language_provider.dart';
import 'providers/database_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    BusinessProfileSchema,
    CustomerSchema,
    ReminderSchema,
    tx.TransactionSchema,
  ], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const KhataDigitalApp(),
    ),
  );
}

class KhataDigitalApp extends ConsumerWidget {
  const KhataDigitalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLanguageAsync = ref.watch(appLanguageProvider);
    final appLanguage = appLanguageAsync.valueOrNull ?? AppLanguage.english;

    return MaterialApp.router(
      title: 'Khata Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      locale: localeFromLanguage(appLanguage),
      supportedLocales: const [Locale('en'), Locale('ur', 'PK')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}

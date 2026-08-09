import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'l10n/app_strings.dart';
import 'providers/providers.dart';
import 'ui/app_shell.dart';

class AnacooApp extends ConsumerWidget {
  const AnacooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageCodeProvider);
    final strings = ref.watch(appStringsProvider);

    return MaterialApp(
      title: strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AnacooTheme.light(),
      darkTheme: AnacooTheme.dark(),
      themeMode: ThemeMode.system,
      locale: Locale(language),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for settings before showing the shell, so the first frame already
    // has the right language and working hours rather than flashing defaults.
    final settings = ref.watch(settingsProvider);
    return settings.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$error'),
          ),
        ),
      ),
      data: (_) => const AppShell(),
    );
  }
}

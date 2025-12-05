import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'src/services/notifications_service.dart';
import 'src/services/timezone_helper.dart';
import 'firebase_options.dart';
import 'src/router.dart';
import 'src/theme.dart';

// Provider solo para tamaño de letra
import 'src/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationsService.init();
  await TimeZoneHelper.initializeTimeZones();

  // Cargar AJUSTES antes de arrancar la app
  final settings = SettingsProvider();
  await settings.loadSettings();

  runApp(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: const AgroSoftApp(),
    ),
  );
}

class AgroSoftApp extends StatelessWidget {
  const AgroSoftApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // Mientras carga
    if (!settings.loaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final double textScale = settings.isLargeFont ? 1.22 : 1.0;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: buildAgroTheme(), // tu theme original intacto

      // Aplicar tamaño de letra global
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },

      routerConfig: appRouter,
    );
  }
}

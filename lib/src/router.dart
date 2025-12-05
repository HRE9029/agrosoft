// ❤️ ROUTER FINAL DEFINITIVO
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ===========================
// AUTH
// ===========================
import 'ui/auth/login_page.dart';
import 'ui/auth/register_page.dart';

// ===========================
// HOME SHELL
// ===========================
import 'ui/home/home_shell.dart';

// ===========================
// CROPS (CATÁLOGO LOCAL)
// ===========================
import 'ui/home/crops/all_crops_page.dart';
import 'ui/home/crops/crop_detail_page.dart';

// ===========================
// MY CROPS
// ===========================
import 'ui/home/crops/my_crops_page.dart';
import 'ui/home/crops/add_crop_page.dart';
import 'ui/home/crops/my_crop_detail_page.dart';

// ===========================
// LISTAS LOCALES
// ===========================
import 'ui/home/diseases/diseases_list_page.dart';
import 'ui/home/pests/pests_list_page.dart';
import 'ui/home/weeds/weeds_list_page.dart';

// ===========================
// DETALLES LOCALES
// ===========================
import 'ui/home/diseases/disease_detail_page.dart';
import 'ui/home/pests/pest_detail_page.dart';
import 'ui/home/weeds/weed_detail_page.dart';

// ===========================
// 🔥 ÚNICA PANTALLA DINÁMICA FIREBASE
// ===========================
import 'ui/home/crops/crop_firebase_detail_page.dart';

// ===========================
// OTRAS PÁGINAS
// ===========================
import 'ui/home/perfil_page.dart';
import 'ui/home/politicas_page.dart';
import 'ui/home/config_page.dart';
import 'ui/home/help_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    // ===========================
    // LOGIN / REGISTER
    // ===========================
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterPage(),
    ),

    // ===========================
    // HOME
    // ===========================
    GoRoute(
      path: '/home',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const HomeShell()),
    ),

    // ===========================
    // CATÁLOGO LOCAL DE CULTIVOS
    // ===========================
    GoRoute(
      path: '/all-crops',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const AllCropsPage()),
    ),
    GoRoute(
      path: '/crop/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaterialPage(
          key: UniqueKey(),
          child: CropDetailPage(id: id), // ⭐ LOCAL
        );
      },
    ),

    // ===========================
    // 🔥 DETALLES FIREBASE (UNA SOLA PANTALLA)
    // ===========================
 GoRoute(
  path: '/details/firebase/:collection/:name',
  builder: (context, state) {
    final collection = state.pathParameters['collection']!;
    final name = state.pathParameters['name']!;
    return FirebaseDetailPage(collection: collection, name: name);
  },
),








    // ===========================
    // LISTAS LOCALES
    // ===========================
    GoRoute(
      path: '/diseases/:cropId',
      pageBuilder: (context, state) {
        final cropId = state.pathParameters['cropId']!;
        final cropName = state.extra as String? ?? "Cultivo";
        return MaterialPage(
          key: UniqueKey(),
          child: DiseasesListPage(cropId: cropId, cropName: cropName),
        );
      },
    ),

    GoRoute(
      path: '/weeds/:cropId',
      pageBuilder: (context, state) {
        final cropId = state.pathParameters['cropId']!;
        final cropName = state.extra as String? ?? "Cultivo";
        return MaterialPage(
          key: UniqueKey(),
          child: WeedsListPage(cropId: cropId, cropName: cropName),
        );
      },
    ),

    GoRoute(
      path: '/pests/:cropId',
      pageBuilder: (context, state) {
        final cropId = state.pathParameters['cropId']!;
        final cropName = state.extra as String? ?? "Cultivo";
        return MaterialPage(
          key: UniqueKey(),
          child: PestsListPage(cropId: cropId, cropName: cropName),
        );
      },
    ),

    // ===========================
    // DETALLES LOCALES
    // ===========================
    GoRoute(
      path: '/pest-detail/:id',
      builder: (_, state) {
        final id = state.pathParameters["id"]!;
        return PestDetailPage(pestId: id);
      },
    ),
    GoRoute(
      path: '/disease-detail/:id',
      builder: (_, state) {
        final id = state.pathParameters["id"]!;
        return DiseaseDetailPage(diseaseId: id);
      },
    ),
    GoRoute(
      path: '/weed-detail/:id',
      builder: (_, state) {
        final id = state.pathParameters["id"]!;
        return WeedDetailPage(weedId: id);
      },
    ),

    // ===========================
    // MY CROPS
    // ===========================
    GoRoute(
      path: '/my-crops',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const MyCropsPage()),
    ),
    GoRoute(
      path: '/add-crop',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const AddCropPage()),
    ),

    GoRoute(
      path: '/my-crop/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaterialPage(
          key: UniqueKey(),
          child: MyCropDetailPage(cropId: id),
        );
      },
    ),

    // ===========================
    // PERFIL / CONFIG / AYUDA
    // ===========================
    GoRoute(
      path: '/profile',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const PerfilPage()),
    ),
    GoRoute(
      path: '/politicas',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const PoliticasPage()),
    ),
    GoRoute(
      path: '/config',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const ConfigPage()),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (_, __) =>
          MaterialPage(key: UniqueKey(), child: const HelpPage()),
    ),
  ],
);

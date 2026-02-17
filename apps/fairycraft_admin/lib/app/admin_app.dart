import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

import '../auth/admin_auth_controller.dart';
import 'admin_router.dart';

class FairyCraftAdminApp extends StatefulWidget {
  const FairyCraftAdminApp({super.key});

  @override
  State<FairyCraftAdminApp> createState() => _FairyCraftAdminAppState();
}

class _FairyCraftAdminAppState extends State<FairyCraftAdminApp> {
  late final _router = createAdminRouter(context.read<AdminAuthController>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FairyCraft Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF01579B)),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}

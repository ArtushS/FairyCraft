import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app/admin_app.dart';
import 'auth/admin_auth_controller.dart';
import 'config/app_environment.dart';
import 'data/repositories/admin_config_repository.dart';
import 'data/repositories/effective_policy_resolver.dart';
import 'data/repositories/logs_repository.dart';
import 'data/repositories/policies_repository.dart';
import 'data/repositories/templates_repository.dart';
import 'data/repositories/test_runs_repository.dart';
import 'data/repositories/tiers_repository.dart';
import 'data/services/admin_gateway_client.dart';
import 'firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromEnvironment();
  final firebaseBootstrap = await FirebaseBootstrap.init(environment);
  final firebaseAuth =
      firebaseBootstrap.firebaseReady ? FirebaseAuth.instance : null;
  final firestore =
      firebaseBootstrap.firebaseReady ? FirebaseFirestore.instance : null;

  final authController = AdminAuthController(
    environment: environment,
    mockMode: firebaseBootstrap.usingMockMode,
    bootstrapError: firebaseBootstrap.error,
    firebaseAuth: firebaseAuth,
  );
  await authController.init();

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        Provider<AppEnvironment>.value(value: environment),
        Provider<FirebaseBootstrapResult>.value(value: firebaseBootstrap),
        ChangeNotifierProvider<AdminAuthController>.value(value: authController),
        Provider<PoliciesRepository>(
          create: (_) => PoliciesRepository(firestore: firestore),
        ),
        Provider<TemplatesRepository>(
          create: (_) => TemplatesRepository(firestore: firestore),
        ),
        Provider<TiersRepository>(
          create: (_) => TiersRepository(firestore: firestore),
        ),
        Provider<LogsRepository>(
          create: (_) => LogsRepository(firestore: firestore),
        ),
        Provider<TestRunsRepository>(
          create: (_) => TestRunsRepository(firestore: firestore),
        ),
        Provider<AdminConfigRepository>(
          create: (_) => AdminConfigRepository(firestore: firestore),
        ),
        Provider<EffectivePolicyResolver>(
          create: _createEffectivePolicyResolver,
        ),
        Provider<AdminGatewayClient>(
          create: (_) => AdminGatewayClient(
            baseUrl: environment.gatewayBaseUrl,
            idTokenProvider: authController.getIdToken,
          ),
        ),
      ],
      child: const FairyCraftAdminApp(),
    ),
  );
}

EffectivePolicyResolver _createEffectivePolicyResolver(BuildContext context) {
  return const EffectivePolicyResolver();
}

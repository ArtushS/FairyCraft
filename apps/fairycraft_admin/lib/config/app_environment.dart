enum AppFlavor { dev, prod }

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.useMockAdmin,
    required this.gatewayBaseUrl,
    required this.allowLocalAdminUidOverrides,
  });

  final AppFlavor flavor;
  final bool useMockAdmin;
  final String gatewayBaseUrl;
  final bool allowLocalAdminUidOverrides;

  bool get isProduction => flavor == AppFlavor.prod;
  bool get isDevelopment => flavor == AppFlavor.dev;

  static AppEnvironment fromEnvironment() {
    const rawFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    final normalizedFlavor = rawFlavor.trim().toLowerCase();
    final flavor = normalizedFlavor == 'prod' ? AppFlavor.prod : AppFlavor.dev;
    const useMockAdminDefine = bool.fromEnvironment(
      'USE_MOCK_ADMIN',
      defaultValue: false,
    );

    return AppEnvironment(
      flavor: flavor,
      useMockAdmin: useMockAdminDefine && flavor == AppFlavor.dev,
      gatewayBaseUrl: const String.fromEnvironment(
        'ADMIN_GATEWAY_URL',
        defaultValue: 'http://localhost:8080',
      ),
      allowLocalAdminUidOverrides:
          flavor == AppFlavor.dev &&
          const bool.fromEnvironment(
            'ENABLE_LOCAL_ADMIN_UID_OVERRIDES',
            defaultValue: true,
          ),
    );
  }
}

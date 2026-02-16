import '../../shared/firestore_utils.dart';

class AdminConfigModel {
  const AdminConfigModel({
    required this.defaultLanguage,
    required this.supportedLanguages,
    required this.safeDefaults,
    required this.providerPlaceholders,
    this.updatedAt,
  });

  final String defaultLanguage;
  final List<String> supportedLanguages;
  final Map<String, dynamic> safeDefaults;
  final Map<String, dynamic> providerPlaceholders;
  final DateTime? updatedAt;

  static const AdminConfigModel fallback = AdminConfigModel(
    defaultLanguage: 'en',
    supportedLanguages: <String>['en', 'ru', 'hy'],
    safeDefaults: <String, dynamic>{
      'safeModeDefault': true,
      'strictSafeModeDefault': true,
      'disallowScaryDefault': true,
      'allowImagesByDefault': true,
    },
    providerPlaceholders: <String, dynamic>{
      'primaryProvider': 'mock',
      'gptModel': 'gpt-4.1-mini',
      'vertexModel': 'gemini-2.0-flash',
      'note': 'Store secrets in environment variables only.',
    },
  );

  factory AdminConfigModel.fromJson(Map<String, dynamic> json) {
    final safeDefaultsRaw = mapFromDynamic(json['safeDefaults']);
    final providerRaw = mapFromDynamic(json['providerPlaceholders']);

    return AdminConfigModel(
      defaultLanguage: json['defaultLanguage']?.toString() ?? fallback.defaultLanguage,
      supportedLanguages: stringListFromDynamic(json['supportedLanguages']).isEmpty
          ? fallback.supportedLanguages
          : stringListFromDynamic(json['supportedLanguages']),
      safeDefaults: safeDefaultsRaw.isEmpty ? fallback.safeDefaults : safeDefaultsRaw,
      providerPlaceholders:
          providerRaw.isEmpty ? fallback.providerPlaceholders : providerRaw,
      updatedAt: dateTimeFromFirestore(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'defaultLanguage': defaultLanguage,
      'supportedLanguages': supportedLanguages,
      'safeDefaults': safeDefaults,
      'providerPlaceholders': providerPlaceholders,
      'updatedAt': dateTimeToIso(updatedAt),
    };
  }

  AdminConfigModel copyWith({
    String? defaultLanguage,
    List<String>? supportedLanguages,
    Map<String, dynamic>? safeDefaults,
    Map<String, dynamic>? providerPlaceholders,
    DateTime? updatedAt,
  }) {
    return AdminConfigModel(
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      safeDefaults: safeDefaults ?? this.safeDefaults,
      providerPlaceholders: providerPlaceholders ?? this.providerPlaceholders,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

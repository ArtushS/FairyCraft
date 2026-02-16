import '../../shared/firestore_utils.dart';

class PolicyScope {
  const PolicyScope({
    required this.ageMin,
    required this.ageMax,
    required this.language,
    required this.tier,
  });

  final int ageMin;
  final int ageMax;
  final String language;
  final String tier;

  static const PolicyScope global = PolicyScope(
    ageMin: 6,
    ageMax: 12,
    language: '*',
    tier: '*',
  );

  factory PolicyScope.fromJson(Map<String, dynamic> json) {
    return PolicyScope(
      ageMin: (json['ageMin'] as num?)?.toInt() ?? 6,
      ageMax: (json['ageMax'] as num?)?.toInt() ?? 12,
      language: json['language']?.toString() ?? '*',
      tier: json['tier']?.toString() ?? '*',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ageMin': ageMin,
      'ageMax': ageMax,
      'language': language,
      'tier': tier,
    };
  }

  bool matches({
    required int age,
    required String languageCode,
    required String tierCode,
  }) {
    final ageMatches = age >= ageMin && age <= ageMax;
    final languageMatches = language == '*' || language == languageCode;
    final tierMatches = tier == '*' || tier == tierCode;
    return ageMatches && languageMatches && tierMatches;
  }

  int specificityScore() {
    final rangeSpan = (ageMax - ageMin).clamp(0, 100);
    final languageScore = language == '*' ? 0 : 50;
    final tierScore = tier == '*' ? 0 : 50;
    final ageScore = 100 - rangeSpan;
    return languageScore + tierScore + ageScore;
  }

  String displayLabel() {
    return 'age $ageMin-$ageMax | lang=$language | tier=$tier';
  }
}

List<PolicyScope> scopeListFromDynamic(dynamic raw) {
  if (raw is List) {
    return raw
        .map((item) => PolicyScope.fromJson(mapFromDynamic(item)))
        .toList(growable: false);
  }
  return <PolicyScope>[PolicyScope.global];
}

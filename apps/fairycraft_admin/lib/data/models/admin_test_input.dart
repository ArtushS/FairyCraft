class AdminTestInput {
  const AdminTestInput({
    required this.age,
    required this.tier,
    required this.language,
    required this.storyIdea,
    required this.heroType,
    required this.heroAge,
    required this.location,
    required this.genre,
    required this.length,
    required this.complexity,
    required this.illustrationsEnabled,
    required this.familyMembers,
    this.familyNames = const <String, String>{},
    this.brothers = const <String>[],
    this.sisters = const <String>[],
    required this.creativity,
    required this.safeMode,
    required this.disableScaryContent,
    required this.requireParentConfirmationForOlder,
  });

  final int age;
  final String tier;
  final String language;
  final String storyIdea;
  final String heroType;
  final int heroAge;
  final String location;
  final String genre;
  final String length;
  final String complexity;
  final bool illustrationsEnabled;
  final Map<String, int> familyMembers;
  final Map<String, String> familyNames;
  final List<String> brothers;
  final List<String> sisters;
  final String creativity;
  final bool safeMode;
  final bool disableScaryContent;
  final bool requireParentConfirmationForOlder;

  Map<String, dynamic> toJson() {
    final normalizedFamilyNames = <String, String>{};
    familyNames.forEach((key, value) {
      final normalizedKey = key.trim();
      final normalizedValue = value.trim();
      if (normalizedKey.isNotEmpty && normalizedValue.isNotEmpty) {
        normalizedFamilyNames[normalizedKey] = normalizedValue;
      }
    });
    final normalizedBrothers = brothers
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final normalizedSisters = sisters
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);

    return <String, dynamic>{
      'age': age,
      'tier': tier,
      'language': language,
      'storyIdea': storyIdea,
      'heroType': heroType,
      'heroAge': heroAge,
      'location': location,
      'genre': genre,
      'length': length,
      'complexity': complexity,
      'illustrationsEnabled': illustrationsEnabled,
      'familyMembers': familyMembers,
      if (normalizedFamilyNames.isNotEmpty)
        'familyNames': normalizedFamilyNames,
      if (normalizedBrothers.isNotEmpty) 'brothers': normalizedBrothers,
      if (normalizedSisters.isNotEmpty) 'sisters': normalizedSisters,
      'creativity': creativity,
      'parentalControls': <String, dynamic>{
        'safeMode': safeMode,
        'disableScaryContent': disableScaryContent,
        'requireParentConfirmationForOlder': requireParentConfirmationForOlder,
      },
    };
  }

  Map<String, dynamic> requestSummary() {
    return <String, dynamic>{
      'tier': tier,
      'language': language,
      'age': age,
      'genre': genre,
      'length': length,
      'complexity': complexity,
      'heroType': heroType,
      'illustrationsEnabled': illustrationsEnabled,
      'hasFamilyNames': familyNames.values
          .map((name) => name.trim())
          .any((name) => name.isNotEmpty),
      'brothersCount': brothers
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .length,
      'sistersCount': sisters
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .length,
    };
  }
}

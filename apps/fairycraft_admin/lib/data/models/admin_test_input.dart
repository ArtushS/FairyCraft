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
  final String creativity;
  final bool safeMode;
  final bool disableScaryContent;
  final bool requireParentConfirmationForOlder;

  Map<String, dynamic> toJson() {
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
      'creativity': creativity,
      'parentalControls': <String, dynamic>{
        'safeMode': safeMode,
        'disableScaryContent': disableScaryContent,
        'requireParentConfirmationForOlder':
            requireParentConfirmationForOlder,
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
    };
  }
}

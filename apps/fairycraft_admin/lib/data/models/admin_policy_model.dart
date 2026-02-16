import '../../shared/firestore_utils.dart';
import 'policy_scope.dart';

class ContentRules {
  const ContentRules({
    required this.safeModeDefault,
    required this.disallowViolence,
    required this.disallowDrugs,
    required this.disallowHate,
    required this.disallowSexualContent,
    required this.disallowReligiousPolitical,
    required this.requireParentConfirmationForOlder,
    required this.disallowScary,
    required this.customBannedWords,
  });

  final bool safeModeDefault;
  final bool disallowViolence;
  final bool disallowDrugs;
  final bool disallowHate;
  final bool disallowSexualContent;
  final bool disallowReligiousPolitical;
  final bool requireParentConfirmationForOlder;
  final bool disallowScary;
  final List<String> customBannedWords;

  static const ContentRules fallback = ContentRules(
    safeModeDefault: true,
    disallowViolence: true,
    disallowDrugs: true,
    disallowHate: true,
    disallowSexualContent: true,
    disallowReligiousPolitical: true,
    requireParentConfirmationForOlder: true,
    disallowScary: true,
    customBannedWords: <String>[],
  );

  factory ContentRules.fromJson(Map<String, dynamic> json) {
    return ContentRules(
      safeModeDefault: json['safeModeDefault'] as bool? ?? fallback.safeModeDefault,
      disallowViolence: json['disallowViolence'] as bool? ?? fallback.disallowViolence,
      disallowDrugs: json['disallowDrugs'] as bool? ?? fallback.disallowDrugs,
      disallowHate: json['disallowHate'] as bool? ?? fallback.disallowHate,
      disallowSexualContent:
          json['disallowSexualContent'] as bool? ?? fallback.disallowSexualContent,
      disallowReligiousPolitical: json['disallowReligiousPolitical'] as bool? ??
          fallback.disallowReligiousPolitical,
      requireParentConfirmationForOlder:
          json['requireParentConfirmationForOlder'] as bool? ??
              fallback.requireParentConfirmationForOlder,
      disallowScary: json['disallowScary'] as bool? ?? fallback.disallowScary,
      customBannedWords: stringListFromDynamic(json['customBannedWords']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'safeModeDefault': safeModeDefault,
      'disallowViolence': disallowViolence,
      'disallowDrugs': disallowDrugs,
      'disallowHate': disallowHate,
      'disallowSexualContent': disallowSexualContent,
      'disallowReligiousPolitical': disallowReligiousPolitical,
      'requireParentConfirmationForOlder': requireParentConfirmationForOlder,
      'disallowScary': disallowScary,
      'customBannedWords': customBannedWords,
    };
  }

  ContentRules copyWith({
    bool? safeModeDefault,
    bool? disallowViolence,
    bool? disallowDrugs,
    bool? disallowHate,
    bool? disallowSexualContent,
    bool? disallowReligiousPolitical,
    bool? requireParentConfirmationForOlder,
    bool? disallowScary,
    List<String>? customBannedWords,
  }) {
    return ContentRules(
      safeModeDefault: safeModeDefault ?? this.safeModeDefault,
      disallowViolence: disallowViolence ?? this.disallowViolence,
      disallowDrugs: disallowDrugs ?? this.disallowDrugs,
      disallowHate: disallowHate ?? this.disallowHate,
      disallowSexualContent: disallowSexualContent ?? this.disallowSexualContent,
      disallowReligiousPolitical:
          disallowReligiousPolitical ?? this.disallowReligiousPolitical,
      requireParentConfirmationForOlder: requireParentConfirmationForOlder ??
          this.requireParentConfirmationForOlder,
      disallowScary: disallowScary ?? this.disallowScary,
      customBannedWords: customBannedWords ?? this.customBannedWords,
    );
  }
}

class PromptConstraints {
  const PromptConstraints({
    required this.maxTokensHint,
    required this.maxCharsHint,
    required this.enforceStructure,
    required this.readingLevel,
  });

  final int maxTokensHint;
  final int maxCharsHint;
  final bool enforceStructure;
  final String readingLevel;

  static const PromptConstraints fallback = PromptConstraints(
    maxTokensHint: 700,
    maxCharsHint: 4500,
    enforceStructure: true,
    readingLevel: 'simple',
  );

  factory PromptConstraints.fromJson(Map<String, dynamic> json) {
    return PromptConstraints(
      maxTokensHint: (json['maxTokensHint'] as num?)?.toInt() ?? fallback.maxTokensHint,
      maxCharsHint: (json['maxCharsHint'] as num?)?.toInt() ?? fallback.maxCharsHint,
      enforceStructure:
          json['enforceStructure'] as bool? ?? fallback.enforceStructure,
      readingLevel: json['readingLevel']?.toString() ?? fallback.readingLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'maxTokensHint': maxTokensHint,
      'maxCharsHint': maxCharsHint,
      'enforceStructure': enforceStructure,
      'readingLevel': readingLevel,
    };
  }

  PromptConstraints copyWith({
    int? maxTokensHint,
    int? maxCharsHint,
    bool? enforceStructure,
    String? readingLevel,
  }) {
    return PromptConstraints(
      maxTokensHint: maxTokensHint ?? this.maxTokensHint,
      maxCharsHint: maxCharsHint ?? this.maxCharsHint,
      enforceStructure: enforceStructure ?? this.enforceStructure,
      readingLevel: readingLevel ?? this.readingLevel,
    );
  }
}

class ImageRules {
  const ImageRules({
    required this.allowImages,
    required this.allowedImageStyles,
  });

  final bool allowImages;
  final List<String> allowedImageStyles;

  static const ImageRules fallback = ImageRules(
    allowImages: true,
    allowedImageStyles: <String>['storybook-watercolor'],
  );

  factory ImageRules.fromJson(Map<String, dynamic> json) {
    return ImageRules(
      allowImages: json['allowImages'] as bool? ?? fallback.allowImages,
      allowedImageStyles: stringListFromDynamic(json['allowedImageStyles']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'allowImages': allowImages,
      'allowedImageStyles': allowedImageStyles,
    };
  }

  ImageRules copyWith({
    bool? allowImages,
    List<String>? allowedImageStyles,
  }) {
    return ImageRules(
      allowImages: allowImages ?? this.allowImages,
      allowedImageStyles: allowedImageStyles ?? this.allowedImageStyles,
    );
  }
}

class AdminPolicyModel {
  const AdminPolicyModel({
    required this.id,
    required this.active,
    required this.scope,
    required this.contentRules,
    required this.promptConstraints,
    required this.imageRules,
    required this.versionStamp,
    this.updatedAt,
  });

  final String id;
  final bool active;
  final PolicyScope scope;
  final ContentRules contentRules;
  final PromptConstraints promptConstraints;
  final ImageRules imageRules;
  final String versionStamp;
  final DateTime? updatedAt;

  factory AdminPolicyModel.fromJson(String id, Map<String, dynamic> json) {
    return AdminPolicyModel(
      id: id,
      active: json['active'] as bool? ?? true,
      scope: PolicyScope.fromJson(mapFromDynamic(json['scope'])),
      contentRules: ContentRules.fromJson(mapFromDynamic(json['contentRules'])),
      promptConstraints:
          PromptConstraints.fromJson(mapFromDynamic(json['promptConstraints'])),
      imageRules: ImageRules.fromJson(mapFromDynamic(json['imageRules'])),
      versionStamp: json['versionStamp']?.toString() ?? 'v1',
      updatedAt: dateTimeFromFirestore(json['updatedAt']),
    );
  }

  factory AdminPolicyModel.fallback({required String id}) {
    return AdminPolicyModel(
      id: id,
      active: true,
      scope: PolicyScope.global,
      contentRules: ContentRules.fallback,
      promptConstraints: PromptConstraints.fallback,
      imageRules: ImageRules.fallback,
      versionStamp: 'v1',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'active': active,
      'scope': scope.toJson(),
      'contentRules': contentRules.toJson(),
      'promptConstraints': promptConstraints.toJson(),
      'imageRules': imageRules.toJson(),
      'versionStamp': versionStamp,
      'updatedAt': dateTimeToIso(updatedAt),
    };
  }

  AdminPolicyModel copyWith({
    bool? active,
    PolicyScope? scope,
    ContentRules? contentRules,
    PromptConstraints? promptConstraints,
    ImageRules? imageRules,
    String? versionStamp,
    DateTime? updatedAt,
  }) {
    return AdminPolicyModel(
      id: id,
      active: active ?? this.active,
      scope: scope ?? this.scope,
      contentRules: contentRules ?? this.contentRules,
      promptConstraints: promptConstraints ?? this.promptConstraints,
      imageRules: imageRules ?? this.imageRules,
      versionStamp: versionStamp ?? this.versionStamp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

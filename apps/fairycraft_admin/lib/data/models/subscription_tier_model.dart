import '../../shared/firestore_utils.dart';

class TierLimits {
  const TierLimits({
    required this.storiesPerDay,
    required this.imagesPerStory,
    required this.maxStoryLength,
    required this.maxContinuationDepth,
    required this.allowVoiceInput,
    required this.allowTts,
    required this.allowPrintOrder,
    required this.allowToyOrder,
  });

  final int storiesPerDay;
  final int imagesPerStory;
  final String maxStoryLength;
  final int maxContinuationDepth;
  final bool allowVoiceInput;
  final bool allowTts;
  final bool allowPrintOrder;
  final bool allowToyOrder;

  factory TierLimits.fromJson(Map<String, dynamic> json) {
    return TierLimits(
      storiesPerDay: (json['storiesPerDay'] as num?)?.toInt() ?? 3,
      imagesPerStory: (json['imagesPerStory'] as num?)?.toInt() ?? 1,
      maxStoryLength: json['maxStoryLength']?.toString() ?? 'short',
      maxContinuationDepth:
          (json['maxContinuationDepth'] as num?)?.toInt() ?? 2,
      allowVoiceInput: json['allowVoiceInput'] as bool? ?? false,
      allowTts: json['allowTTS'] as bool? ?? false,
      allowPrintOrder: json['allowPrintOrder'] as bool? ?? false,
      allowToyOrder: json['allowToyOrder'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'storiesPerDay': storiesPerDay,
      'imagesPerStory': imagesPerStory,
      'maxStoryLength': maxStoryLength,
      'maxContinuationDepth': maxContinuationDepth,
      'allowVoiceInput': allowVoiceInput,
      'allowTTS': allowTts,
      'allowPrintOrder': allowPrintOrder,
      'allowToyOrder': allowToyOrder,
    };
  }

  TierLimits copyWith({
    int? storiesPerDay,
    int? imagesPerStory,
    String? maxStoryLength,
    int? maxContinuationDepth,
    bool? allowVoiceInput,
    bool? allowTts,
    bool? allowPrintOrder,
    bool? allowToyOrder,
  }) {
    return TierLimits(
      storiesPerDay: storiesPerDay ?? this.storiesPerDay,
      imagesPerStory: imagesPerStory ?? this.imagesPerStory,
      maxStoryLength: maxStoryLength ?? this.maxStoryLength,
      maxContinuationDepth: maxContinuationDepth ?? this.maxContinuationDepth,
      allowVoiceInput: allowVoiceInput ?? this.allowVoiceInput,
      allowTts: allowTts ?? this.allowTts,
      allowPrintOrder: allowPrintOrder ?? this.allowPrintOrder,
      allowToyOrder: allowToyOrder ?? this.allowToyOrder,
    );
  }
}

class SubscriptionTierModel {
  const SubscriptionTierModel({
    required this.id,
    required this.active,
    required this.limits,
    this.updatedAt,
  });

  final String id;
  final bool active;
  final TierLimits limits;
  final DateTime? updatedAt;

  factory SubscriptionTierModel.fromJson(String id, Map<String, dynamic> json) {
    return SubscriptionTierModel(
      id: id,
      active: json['active'] as bool? ?? true,
      limits: TierLimits.fromJson(mapFromDynamic(json['limits'])),
      updatedAt: dateTimeFromFirestore(json['updatedAt']),
    );
  }

  factory SubscriptionTierModel.fallback(String id) {
    switch (id) {
      case 'premium':
        return SubscriptionTierModel(
          id: 'premium',
          active: true,
          limits: const TierLimits(
            storiesPerDay: 30,
            imagesPerStory: 8,
            maxStoryLength: 'long',
            maxContinuationDepth: 16,
            allowVoiceInput: true,
            allowTts: true,
            allowPrintOrder: true,
            allowToyOrder: true,
          ),
        );
      case 'pro':
        return SubscriptionTierModel(
          id: 'pro',
          active: true,
          limits: const TierLimits(
            storiesPerDay: 10,
            imagesPerStory: 4,
            maxStoryLength: 'medium',
            maxContinuationDepth: 8,
            allowVoiceInput: true,
            allowTts: true,
            allowPrintOrder: true,
            allowToyOrder: false,
          ),
        );
      default:
        return SubscriptionTierModel(
          id: 'free',
          active: true,
          limits: const TierLimits(
            storiesPerDay: 3,
            imagesPerStory: 1,
            maxStoryLength: 'short',
            maxContinuationDepth: 3,
            allowVoiceInput: false,
            allowTts: false,
            allowPrintOrder: false,
            allowToyOrder: false,
          ),
        );
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'active': active,
      'limits': limits.toJson(),
      'updatedAt': dateTimeToIso(updatedAt),
    };
  }

  SubscriptionTierModel copyWith({
    bool? active,
    TierLimits? limits,
    DateTime? updatedAt,
  }) {
    return SubscriptionTierModel(
      id: id,
      active: active ?? this.active,
      limits: limits ?? this.limits,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

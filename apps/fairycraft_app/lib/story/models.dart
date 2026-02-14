import 'dart:convert';

class StoryChoice {
  StoryChoice({required this.id, required this.label});

  final String id;
  final String label;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
  };

  static StoryChoice fromJson(Map<String, dynamic> json) {
    return StoryChoice(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class StoryChapter {
  StoryChapter({
    required this.index,
    this.title,
    required this.text,
    required this.choices,
  });

  final int index;
  final String? title;
  final String text;
  final List<StoryChoice> choices;

  Map<String, dynamic> toJson() => {
    'index': index,
    'title': title,
    'text': text,
    'choices': choices.map((choice) => choice.toJson()).toList(growable: false),
  };

  static StoryChapter fromJson(Map<String, dynamic> json) {
    final dynamicChoices = json['choices'];
    final choices = <StoryChoice>[];
    if (dynamicChoices is List) {
      for (final item in dynamicChoices) {
        if (item is Map<String, dynamic>) {
          choices.add(StoryChoice.fromJson(item));
        } else if (item is Map) {
          choices.add(StoryChoice.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return StoryChapter(
      index: json['index'] as int? ?? 1,
      title: json['title'] as String?,
      text: json['text'] as String? ?? '',
      choices: choices,
    );
  }
}

class StoryRecord {
  StoryRecord({
    required this.storyId,
    required this.storyLang,
    required this.title,
    required this.chapters,
    required this.createdAt,
    this.lastImagePrompt,
  });

  final String storyId;
  final String storyLang;
  final String title;
  final List<StoryChapter> chapters;
  final DateTime createdAt;
  final String? lastImagePrompt;

  StoryRecord copyWith({
    List<StoryChapter>? chapters,
    String? lastImagePrompt,
  }) {
    return StoryRecord(
      storyId: storyId,
      storyLang: storyLang,
      title: title,
      chapters: chapters ?? this.chapters,
      createdAt: createdAt,
      lastImagePrompt: lastImagePrompt ?? this.lastImagePrompt,
    );
  }

  Map<String, dynamic> toJson() => {
    'storyId': storyId,
    'storyLang': storyLang,
    'title': title,
    'chapters': chapters.map((chapter) => chapter.toJson()).toList(growable: false),
    'createdAt': createdAt.toIso8601String(),
    'lastImagePrompt': lastImagePrompt,
  };

  static StoryRecord fromJson(Map<String, dynamic> json) {
    final dynamicChapters = json['chapters'];
    final chapters = <StoryChapter>[];
    if (dynamicChapters is List) {
      for (final item in dynamicChapters) {
        if (item is Map<String, dynamic>) {
          chapters.add(StoryChapter.fromJson(item));
        } else if (item is Map) {
          chapters.add(StoryChapter.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return StoryRecord(
      storyId: json['storyId'] as String? ?? '',
      storyLang: json['storyLang'] as String? ?? 'en',
      title: json['title'] as String? ?? 'FairyCraft Story',
      chapters: chapters,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      lastImagePrompt: json['lastImagePrompt'] as String?,
    );
  }
}

class StoryRequestPayload {
  StoryRequestPayload({
    required this.action,
    required this.storyLang,
    this.storyId,
    this.ageGroup,
    this.storyLength,
    this.creativityLevel,
    this.hero,
    this.location,
    this.storyType,
    this.idea,
    this.choiceId,
    this.imageEnabled = false,
    this.prompt,
  });

  final String action;
  final String storyLang;
  final String? storyId;
  final String? ageGroup;
  final String? storyLength;
  final double? creativityLevel;
  final String? hero;
  final String? location;
  final String? storyType;
  final String? idea;
  final String? choiceId;
  final bool imageEnabled;
  final String? prompt;

  Map<String, dynamic> toJson(String requestId) {
    return {
      'requestId': requestId,
      'action': action,
      'storyLang': storyLang,
      if (ageGroup != null) 'ageGroup': ageGroup,
      if (storyLength != null) 'storyLength': storyLength,
      if (creativityLevel != null) 'creativityLevel': creativityLevel,
      if (hero != null || location != null || storyType != null || idea != null)
        'selection': {
          if (hero != null) 'hero': hero,
          if (location != null) 'location': location,
          if (storyType != null) 'storyType': storyType,
          if (idea != null) 'idea': idea,
        },
      if (storyId != null) 'storyId': storyId,
      if (choiceId != null)
        'choice': {
          'id': choiceId,
        },
      if (prompt != null) 'prompt': prompt,
      'image': {
        'enabled': imageEnabled,
      },
    };
  }
}

class StoryResponsePayload {
  StoryResponsePayload({
    required this.requestId,
    required this.ok,
    this.error,
    this.safeMessage,
    this.storyId,
    this.title,
    this.chapter,
    this.chapters,
    this.imagePrompt,
    this.imageDisabled = false,
  });

  final String requestId;
  final bool ok;
  final String? error;
  final String? safeMessage;
  final String? storyId;
  final String? title;
  final StoryChapter? chapter;
  final List<StoryChapter>? chapters;
  final String? imagePrompt;
  final bool imageDisabled;

  static StoryResponsePayload fromJson(Map<String, dynamic> json) {
    StoryChapter? chapter;
    final dynamicChapter = json['chapter'];
    if (dynamicChapter is Map<String, dynamic>) {
      chapter = StoryChapter.fromJson(dynamicChapter);
    } else if (dynamicChapter is Map) {
      chapter = StoryChapter.fromJson(Map<String, dynamic>.from(dynamicChapter));
    }

    List<StoryChapter>? chapters;
    final dynamicChapters = json['chapters'];
    if (dynamicChapters is List) {
      chapters = <StoryChapter>[];
      for (final item in dynamicChapters) {
        if (item is Map<String, dynamic>) {
          chapters.add(StoryChapter.fromJson(item));
        } else if (item is Map) {
          chapters.add(StoryChapter.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final dynamicImage = json['image'];
    String? imagePrompt;
    bool imageDisabled = false;
    if (dynamicImage is Map) {
      imagePrompt = dynamicImage['prompt'] as String?;
      imageDisabled = dynamicImage['disabled'] as bool? ?? false;
    }

    return StoryResponsePayload(
      requestId: json['requestId'] as String? ?? '',
      ok: json['ok'] as bool? ?? false,
      error: json['error'] as String?,
      safeMessage: json['safeMessage'] as String?,
      storyId: json['storyId'] as String?,
      title: json['title'] as String?,
      chapter: chapter,
      chapters: chapters,
      imagePrompt: imagePrompt,
      imageDisabled: imageDisabled,
    );
  }
}

String storyRecordsToJson(List<StoryRecord> records) {
  return jsonEncode(records.map((record) => record.toJson()).toList(growable: false));
}

List<StoryRecord> storyRecordsFromJson(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    return const <StoryRecord>[];
  }

  return decoded
      .whereType<Map>()
      .map((map) => StoryRecord.fromJson(Map<String, dynamic>.from(map)))
      .toList(growable: false);
}

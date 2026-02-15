class SttMode {
  const SttMode._();

  static const String direct = 'direct';
  static const String proxy = 'proxy';
}

enum SttLanguage { auto, armenian, russian, english }

extension SttLanguageX on SttLanguage {
  String get storageCode {
    switch (this) {
      case SttLanguage.auto:
        return 'auto';
      case SttLanguage.armenian:
        return 'hy';
      case SttLanguage.russian:
        return 'ru';
      case SttLanguage.english:
        return 'en';
    }
  }

  String get label {
    switch (this) {
      case SttLanguage.auto:
        return 'Auto';
      case SttLanguage.armenian:
        return 'Armenian';
      case SttLanguage.russian:
        return 'Russian';
      case SttLanguage.english:
        return 'English';
    }
  }

  List<String> get apiLanguageCandidates {
    switch (this) {
      case SttLanguage.auto:
        return const <String>['auto'];
      case SttLanguage.armenian:
        return const <String>['hye', 'hy', 'hy-AM'];
      case SttLanguage.russian:
        return const <String>['rus', 'ru', 'ru-RU'];
      case SttLanguage.english:
        return const <String>['eng', 'en', 'en-US'];
    }
  }
}

SttLanguage sttLanguageFromStorageCode(String raw) {
  final normalized = raw.trim().toLowerCase();
  switch (normalized) {
    case 'app':
      return SttLanguage.auto;
    case 'hy':
    case 'hye':
    case 'hy-am':
      return SttLanguage.armenian;
    case 'ru':
    case 'rus':
    case 'ru-ru':
      return SttLanguage.russian;
    case 'en':
    case 'eng':
    case 'en-us':
      return SttLanguage.english;
    default:
      return SttLanguage.auto;
  }
}

SttLanguage sttLanguageFromAppLocaleCode(String raw) {
  final normalized = raw.trim().toLowerCase();
  switch (normalized) {
    case 'hy':
      return SttLanguage.armenian;
    case 'ru':
      return SttLanguage.russian;
    default:
      return SttLanguage.english;
  }
}

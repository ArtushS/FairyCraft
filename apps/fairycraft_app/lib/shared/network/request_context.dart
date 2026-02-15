import '../../settings/settings_controller.dart';

class RequestContext {
  RequestContext(this._settingsController);

  final SettingsController _settingsController;

  String get localeCode {
    final normalized = _settingsController.localeCode.trim().toLowerCase();
    switch (normalized) {
      case 'ru':
      case 'hy':
      case 'en':
        return normalized;
      default:
        return 'en';
    }
  }

  Map<String, String> headers({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Accept-Language': localeCode,
      'X-App-Lang': localeCode,
    };

    if (extra != null && extra.isNotEmpty) {
      headers.addAll(extra);
    }

    return headers;
  }
}

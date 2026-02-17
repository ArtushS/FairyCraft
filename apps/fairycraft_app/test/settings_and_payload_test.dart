import 'package:fairycraft_app/features/settings/application/settings_controller.dart';
import 'package:fairycraft_app/story/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists parental control toggles', () async {
    final controller = await SettingsController.load();

    await controller.setSafeMode(false);
    await controller.setDisableScaryContent(false);
    await controller.setRequireParentConfirmationForOlder(false);

    final reloaded = await SettingsController.load();
    expect(reloaded.safeMode, isFalse);
    expect(reloaded.disableScaryContent, isFalse);
    expect(reloaded.requireParentConfirmationForOlder, isFalse);
  });

  test('story request payload omits empty names and keeps valid counts', () {
    final payload = StoryRequestPayload(
      action: 'generate',
      storyLang: 'en',
      familyMembers: <String, int>{'mom': 1, 'brother': 2, 'dad': 0, '': 5},
      familyNames: <String, String>{
        'mom': ' Anna ',
        'dad': '   ',
        '': 'Ignored',
      },
      brothers: <String>[' Tom ', '  '],
      sisters: <String>['', ' Lia '],
      parentalControls: const <String, bool>{
        'safeMode': true,
        'disableScaryContent': true,
        'requireParentConfirmationForOlder': true,
      },
      illustrationsEnabled: true,
      imageEnabled: true,
    );

    final json = payload.toJson('request-1');

    expect(json['familyMembers'], <String, int>{'mom': 1, 'brother': 2});
    expect(json['familyNames'], <String, String>{'mom': 'Anna'});
    expect(json['brothers'], <String>['Tom']);
    expect(json['sisters'], <String>['Lia']);

    final emptyNamesPayload = StoryRequestPayload(
      action: 'generate',
      storyLang: 'en',
      familyNames: const <String, String>{'mom': '   '},
      brothers: const <String>[' '],
      sisters: const <String>[],
    );
    final emptyJson = emptyNamesPayload.toJson('request-2');

    expect(emptyJson.containsKey('familyNames'), isFalse);
    expect(emptyJson.containsKey('brothers'), isFalse);
    expect(emptyJson.containsKey('sisters'), isFalse);
  });
}

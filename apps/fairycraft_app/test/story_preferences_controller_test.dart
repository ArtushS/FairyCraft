import 'package:fairycraft_app/story/story_preferences_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists family names and sibling names with normalization', () async {
    final controller = await StoryPreferencesController.load();

    await controller.setFamilyNameMom('  Anna  ');
    await controller.setFamilyNameDad('   ');
    await controller.setFamilyNameGrandma(' Mariam ');
    await controller.setFamilyNameGrandpa('\n');
    await controller.setBrothersNames(<String>['  Tom  ', '   ', 'Ben']);
    await controller.setSistersNames(<String>['', '  Lia  ']);

    expect(controller.familyNameMom, 'Anna');
    expect(controller.familyNameDad, '');
    expect(controller.familyNameGrandma, 'Mariam');
    expect(controller.familyNameGrandpa, '');

    expect(controller.nonEmptyFamilyNames, <String, String>{
      StoryPreferencesController.memberMom: 'Anna',
      StoryPreferencesController.memberGrandma: 'Mariam',
    });
    expect(controller.nonEmptyBrothersNames, <String>['Tom', 'Ben']);
    expect(controller.nonEmptySistersNames, <String>['Lia']);

    final reloaded = await StoryPreferencesController.load();
    expect(reloaded.familyNameMom, 'Anna');
    expect(reloaded.familyNameDad, '');
    expect(reloaded.nonEmptyBrothersNames, <String>['Tom', 'Ben']);
    expect(reloaded.nonEmptySistersNames, <String>['Lia']);
  });
}

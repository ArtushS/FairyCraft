import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';

class StorageAssetService {
  StorageAssetService._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Map<String, Future<String>> _urlCache =
      <String, Future<String>>{};

  // ====== ROOT PATHS ======
  static const String _heroBase = 'icons/hero';
  static const String _locationBase = 'icons/location';
  static const String _styleBase = 'icons/style';

  static const String placeholderPath = 'icons/placeholder.png';
  static const String settingsIconPath = 'icons/ui_settings.png';

  // ====== HERO LIST ======
  static const List<String> heroIcons = <String>[
    'character_bear.png',
    'character_boy.png',
    'character_cat.png',
    'character_dragon.png',
    'character_elefent.png',
    'character_father.png',
    'character_girl.png',
    'character_grandfather.png',
    'character_grandmother.png',
    'character_hors.png',
    'character_mother.png',
    'character_prince.png',
    'character_princese.png',
    'character_unicorn.png',
    'character_wolf.png',
  ];

  // ====== LOCATION LIST ======
  static const List<String> locationIcons = <String>[
    'dark_castle.png',
    'enchanted_forest.png',
    'fairy_castle.png',
    'fairytale_kingdom.png',
    'harbor_village.png',
    'ice_palace.png',
    'magic_forest.png',
    'mushroom_village.png',
    'sky_kingdom.png',
    'storybook_castle.png',
    'volcano_realm.png',
    'windmill_village.png',
  ];

  // ====== STYLE LIST ======
  static const List<String> styleIcons = <String>[
    'dark_magic.png',
    'item_magic_book.png',
    'item_treasure_chest.png',
    'style_moon_fairy.png',
    'ui_mystery_choice.png',
  ];

  // ====== URL FETCH ======
  static Future<String> getDownloadUrl(String path) {
    return _urlCache.putIfAbsent(path, () {
      final ref = _storage.ref(path);
      return ref.getDownloadURL();
    });
  }

  static Future<String> heroUrl(String file) =>
      getDownloadUrl('$_heroBase/$file');

  static Future<String> locationUrl(String file) =>
      getDownloadUrl('$_locationBase/$file');

  static Future<String> styleUrl(String file) =>
      getDownloadUrl('$_styleBase/$file');

  static Future<String> placeholderUrl() => getDownloadUrl(placeholderPath);

  static Future<String> settingsIconUrl() => getDownloadUrl(settingsIconPath);

  static void clearUrlCache() {
    _urlCache.clear();
  }

  // ====== RANDOM (TICE) ======
  static String randomHero() => heroIcons[Random().nextInt(heroIcons.length)];

  static String randomLocation() =>
      locationIcons[Random().nextInt(locationIcons.length)];

  static String randomStyle() =>
      styleIcons[Random().nextInt(styleIcons.length)];
}

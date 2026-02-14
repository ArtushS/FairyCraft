import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'story_repository.dart';

class SharedPreferencesStoryRepository implements StoryRepository {
  SharedPreferencesStoryRepository._(this._prefs);

  static const _storiesKey = 'fairycraft_saved_stories_v1';

  final SharedPreferences _prefs;

  static Future<SharedPreferencesStoryRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesStoryRepository._(prefs);
  }

  @override
  Future<StoryRecord?> getStory(String storyId) async {
    final stories = await listStories();
    for (final story in stories) {
      if (story.storyId == storyId) {
        return story;
      }
    }
    return null;
  }

  @override
  Future<List<StoryRecord>> listStories() async {
    final raw = _prefs.getString(_storiesKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <StoryRecord>[];
    }

    return storyRecordsFromJson(raw);
  }

  @override
  Future<void> saveStory(StoryRecord record) async {
    final stories = await listStories();
    final updated = <StoryRecord>[record];
    for (final story in stories) {
      if (story.storyId != record.storyId) {
        updated.add(story);
      }
    }

    await _prefs.setString(_storiesKey, storyRecordsToJson(updated));
  }
}

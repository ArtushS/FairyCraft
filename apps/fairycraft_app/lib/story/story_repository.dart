import 'models.dart';

abstract class StoryRepository {
  Future<List<StoryRecord>> listStories();
  Future<StoryRecord?> getStory(String storyId);
  Future<void> saveStory(StoryRecord record);
}

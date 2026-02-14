import 'models.dart';
import 'story_service.dart';

class ImageGenerationService {
  ImageGenerationService(this._storyService);

  final StoryService _storyService;

  Future<StoryResponsePayload> generateIllustration({
    required StoryRecord story,
    String? prompt,
  }) {
    return _storyService.illustrateStory(story: story, prompt: prompt);
  }
}

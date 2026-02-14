import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../story/shared_preferences_story_repository.dart';
import '../story/models.dart';

class MyStoriesPage extends StatelessWidget {
  const MyStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<SharedPreferencesStoryRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('My stories')),
      body: FutureBuilder<List<StoryRecord>>(
        future: repository.listStories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stories = snapshot.data!;
          if (stories.isEmpty) {
            return const Center(child: Text('No stories yet.'));
          }

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return ListTile(
                title: Text(story.title),
                subtitle: Text('Chapters: ${story.chapters.length}'),
                onTap: () => context.go('/story-reader', extra: story),
              );
            },
          );
        },
      ),
    );
  }
}


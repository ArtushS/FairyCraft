import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/nav.dart';
import '../l10n/l10n.dart';
import '../story/models.dart';
import '../story/shared_preferences_story_repository.dart';

class MyStoriesPage extends StatelessWidget {
  const MyStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repository = context.read<SharedPreferencesStoryRepository>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myStoriesTitle)),
      body: FutureBuilder<List<StoryRecord>>(
        future: repository.listStories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stories = snapshot.data!;
          if (stories.isEmpty) {
            return Center(child: Text(l10n.myStoriesEmpty));
          }

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return ListTile(
                title: Text(story.title),
                subtitle: Text(l10n.myStoriesChaptersCount(story.chapters.length)),
                onTap: () => Nav.toStoryReader(context, story),
              );
            },
          );
        },
      ),
    );
  }
}

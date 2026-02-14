class StoryCatalog {
  StoryCatalog({
    required this.heroes,
    required this.locations,
    required this.storyTypes,
  });

  final List<String> heroes;
  final List<String> locations;
  final List<String> storyTypes;
}

abstract class StoryCatalogRepository {
  Future<StoryCatalog> loadCatalog();
}

class StubStoryCatalogRepository implements StoryCatalogRepository {
  @override
  Future<StoryCatalog> loadCatalog() async {
    return StoryCatalog(
      heroes: const <String>['Luna', 'Aram', 'Mila', 'Noah'],
      locations: const <String>['Glow Forest', 'Silver Lake', 'Cloud Valley', 'Rainbow Village'],
      storyTypes: const <String>['Adventure', 'Friendship', 'Mystery', 'Learning'],
    );
  }
}

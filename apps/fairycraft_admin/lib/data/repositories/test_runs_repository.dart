import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/test_run_model.dart';

class TestRunsRepository {
  TestRunsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final Map<String, TestRunModel> _local = <String, TestRunModel>{};

  String createId() {
    if (_firestore == null) {
      return 'run_${DateTime.now().millisecondsSinceEpoch}';
    }
    return _firestore.collection('test_runs_v1').doc().id;
  }

  Future<void> save(TestRunModel run) async {
    _local[run.id] = run;
    if (_firestore == null) {
      return;
    }

    await _firestore.collection('test_runs_v1').doc(run.id).set(run.toJson());
  }

  Future<List<TestRunModel>> fetchRecent({int limit = 50}) async {
    if (_firestore == null) {
      final runs = _local.values.toList(growable: false);
      runs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return runs.take(limit).toList(growable: false);
    }

    final snapshot = await _firestore
        .collection('test_runs_v1')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => TestRunModel.fromJson(doc.id, doc.data()))
        .toList(growable: false);
  }
}

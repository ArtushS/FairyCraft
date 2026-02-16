import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_policy_model.dart';

class PoliciesRepository {
  PoliciesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final Map<String, AdminPolicyModel> _local = <String, AdminPolicyModel>{};

  String createId() {
    if (_firestore == null) {
      return 'policy_${DateTime.now().millisecondsSinceEpoch}';
    }
    return _firestore.collection('policies_v1').doc().id;
  }

  Future<List<AdminPolicyModel>> fetchAll() async {
    if (_firestore == null) {
      if (_local.isEmpty) {
        final seed = AdminPolicyModel.fallback(id: 'default_policy');
        _local[seed.id] = seed;
      }
      return _sorted(_local.values.toList(growable: false));
    }

    final snapshot = await _firestore.collection('policies_v1').get();
    if (snapshot.docs.isEmpty) {
      final seed = AdminPolicyModel.fallback(id: 'default_policy').copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      await save(seed);
      return <AdminPolicyModel>[seed];
    }

    return _sorted(
      snapshot.docs
          .map((doc) => AdminPolicyModel.fromJson(doc.id, doc.data()))
          .toList(growable: false),
    );
  }

  Future<void> save(AdminPolicyModel model) async {
    final prepared = model.copyWith(updatedAt: DateTime.now().toUtc());
    _local[prepared.id] = prepared;
    if (_firestore == null) {
      return;
    }

    await _firestore.collection('policies_v1').doc(prepared.id).set(
          prepared.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> delete(String id) async {
    _local.remove(id);
    if (_firestore == null) {
      return;
    }
    await _firestore.collection('policies_v1').doc(id).delete();
  }

  List<AdminPolicyModel> _sorted(List<AdminPolicyModel> values) {
    values.sort((a, b) {
      final aTime = a.updatedAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.updatedAt?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    });
    return values;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_policy_model.dart';

class PolicyBackfillSummary {
  const PolicyBackfillSummary({
    required this.scanned,
    required this.updated,
    required this.skipped,
  });

  final int scanned;
  final int updated;
  final int skipped;
}

class PoliciesRepository {
  PoliciesRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

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
      final seed = AdminPolicyModel.fallback(
        id: 'default_policy',
      ).copyWith(updatedAt: DateTime.now().toUtc());
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

    await _firestore
        .collection('policies_v1')
        .doc(prepared.id)
        .set(prepared.toJson(), SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    _local.remove(id);
    if (_firestore == null) {
      return;
    }
    await _firestore.collection('policies_v1').doc(id).delete();
  }

  Future<PolicyBackfillSummary> backfillAllowPersonalNames() async {
    if (_firestore == null) {
      if (_local.isEmpty) {
        await fetchAll();
      }
      final scanned = _local.length;
      return PolicyBackfillSummary(
        scanned: scanned,
        updated: 0,
        skipped: scanned,
      );
    }

    final snapshot = await _firestore.collection('policies_v1').get();
    var scanned = 0;
    var updated = 0;
    var skipped = 0;
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      scanned++;
      final data = doc.data();
      final contentRulesDynamic = data['contentRules'];
      final contentRules = contentRulesDynamic is Map<String, dynamic>
          ? contentRulesDynamic
          : contentRulesDynamic is Map
          ? Map<String, dynamic>.from(contentRulesDynamic)
          : <String, dynamic>{};
      if (contentRules.containsKey('allowPersonalNames')) {
        skipped++;
        continue;
      }

      updated++;
      batch.set(doc.reference, <String, dynamic>{
        'contentRules': <String, dynamic>{'allowPersonalNames': true},
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }, SetOptions(merge: true));
    }

    if (updated > 0) {
      await batch.commit();
    }

    return PolicyBackfillSummary(
      scanned: scanned,
      updated: updated,
      skipped: skipped,
    );
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

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_config_model.dart';

class AdminConfigRepository {
  AdminConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  AdminConfigModel _localConfig = AdminConfigModel.fallback;

  Future<AdminConfigModel> load() async {
    if (_firestore == null) {
      return _localConfig;
    }

    final snapshot =
        await _firestore.collection('admin_config').doc('v1').get();
    if (!snapshot.exists) {
      await _firestore
          .collection('admin_config')
          .doc('v1')
          .set(AdminConfigModel.fallback.toJson());
      return AdminConfigModel.fallback;
    }
    final data = snapshot.data() ?? <String, dynamic>{};
    return AdminConfigModel.fromJson(data);
  }

  Future<void> save(AdminConfigModel config) async {
    _localConfig = config;
    if (_firestore == null) {
      return;
    }

    await _firestore.collection('admin_config').doc('v1').set(
          config.copyWith(updatedAt: DateTime.now().toUtc()).toJson(),
          SetOptions(merge: true),
        );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/generation_log_model.dart';

class LogsRepository {
  LogsRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  Future<List<GenerationLogModel>> fetchRecent({
    String? status,
    String? provider,
    String? tier,
    String? language,
    int limit = 200,
  }) async {
    if (_firestore == null) {
      return <GenerationLogModel>[];
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('generation_logs_v1')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      if (provider != null && provider.isNotEmpty) {
        query = query.where('provider', isEqualTo: provider);
      }
      if (tier != null && tier.isNotEmpty) {
        query = query.where('tier', isEqualTo: tier);
      }
      if (language != null && language.isNotEmpty) {
        query = query.where('language', isEqualTo: language);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => GenerationLogModel.fromJson(doc.id, doc.data()))
          .toList(growable: false);
    } catch (_) {
      final snapshot = await _firestore
          .collection('generation_logs_v1')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => GenerationLogModel.fromJson(doc.id, doc.data()))
          .where((item) {
            final statusOk = status == null || status.isEmpty || item.status == status;
            final providerOk =
                provider == null || provider.isEmpty || item.provider == provider;
            final tierOk = tier == null || tier.isEmpty || item.tier == tier;
            final languageOk =
                language == null || language.isEmpty || item.language == language;
            return statusOk && providerOk && tierOk && languageOk;
          })
          .toList(growable: false);
    }
  }
}

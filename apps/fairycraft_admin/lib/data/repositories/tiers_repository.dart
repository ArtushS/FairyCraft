import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/subscription_tier_model.dart';

class TiersRepository {
  TiersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final Map<String, SubscriptionTierModel> _local =
      <String, SubscriptionTierModel>{};

  static const List<String> _defaultTierIds = <String>[
    'free',
    'pro',
    'premium',
  ];

  Future<List<SubscriptionTierModel>> fetchAll() async {
    if (_firestore == null) {
      if (_local.isEmpty) {
        for (final tierId in _defaultTierIds) {
          _local[tierId] = SubscriptionTierModel.fallback(tierId);
        }
      }
      return _sorted(_local.values.toList(growable: false));
    }

    final snapshot = await _firestore.collection('subscription_tiers_v1').get();
    if (snapshot.docs.isEmpty) {
      for (final tierId in _defaultTierIds) {
        await save(SubscriptionTierModel.fallback(tierId));
      }
      return _defaultTierIds
          .map(SubscriptionTierModel.fallback)
          .toList(growable: false);
    }

    return _sorted(
      snapshot.docs
          .map((doc) => SubscriptionTierModel.fromJson(doc.id, doc.data()))
          .toList(growable: false),
    );
  }

  Future<void> save(SubscriptionTierModel model) async {
    final prepared = model.copyWith(updatedAt: DateTime.now().toUtc());
    _local[model.id] = prepared;
    if (_firestore == null) {
      return;
    }

    await _firestore.collection('subscription_tiers_v1').doc(model.id).set(
          prepared.toJson(),
          SetOptions(merge: true),
        );
  }

  List<SubscriptionTierModel> _sorted(List<SubscriptionTierModel> values) {
    values.sort((a, b) => a.id.compareTo(b.id));
    return values;
  }
}

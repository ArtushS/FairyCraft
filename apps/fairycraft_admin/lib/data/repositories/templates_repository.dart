import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/style_template_model.dart';

class TemplatesRepository {
  TemplatesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final Map<String, StyleTemplateModel> _local =
      <String, StyleTemplateModel>{};

  String createId() {
    if (_firestore == null) {
      return 'template_${DateTime.now().millisecondsSinceEpoch}';
    }
    return _firestore.collection('style_templates_v1').doc().id;
  }

  Future<List<StyleTemplateModel>> fetchAll() async {
    if (_firestore == null) {
      return _sorted(_local.values.toList(growable: false));
    }

    final snapshot = await _firestore.collection('style_templates_v1').get();
    return _sorted(
      snapshot.docs
          .map((doc) => StyleTemplateModel.fromJson(doc.id, doc.data()))
          .toList(growable: false),
    );
  }

  Future<void> save(StyleTemplateModel model) async {
    final prepared = model.copyWith(updatedAt: DateTime.now().toUtc());
    _local[prepared.id] = prepared;

    if (_firestore == null) {
      return;
    }

    await _firestore.collection('style_templates_v1').doc(prepared.id).set(
          prepared.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<void> delete(String id) async {
    _local.remove(id);
    if (_firestore == null) {
      return;
    }
    await _firestore.collection('style_templates_v1').doc(id).delete();
  }

  List<StyleTemplateModel> _sorted(List<StyleTemplateModel> values) {
    values.sort((a, b) {
      final aTime = a.updatedAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.updatedAt?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    });
    return values;
  }
}

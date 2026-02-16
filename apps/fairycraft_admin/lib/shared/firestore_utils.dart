import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? dateTimeFromFirestore(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is Timestamp) {
    return raw.toDate().toUtc();
  }
  if (raw is DateTime) {
    return raw.toUtc();
  }
  if (raw is String) {
    final parsed = DateTime.tryParse(raw);
    return parsed?.toUtc();
  }
  if (raw is int) {
    return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
  }
  return null;
}

String? dateTimeToIso(DateTime? value) => value?.toUtc().toIso8601String();

List<String> stringListFromDynamic(dynamic raw) {
  if (raw is List) {
    return raw.map((item) => item.toString()).toList(growable: false);
  }
  return <String>[];
}

Map<String, dynamic> mapFromDynamic(dynamic raw) {
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return raw.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
  return <String, dynamic>{};
}

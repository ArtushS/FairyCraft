import '../../shared/firestore_utils.dart';

class TestRunModel {
  const TestRunModel({
    required this.id,
    required this.createdAt,
    required this.adminUid,
    required this.inputPayload,
    required this.composedPayload,
    required this.response,
    required this.status,
  });

  final String id;
  final DateTime createdAt;
  final String adminUid;
  final Map<String, dynamic> inputPayload;
  final Map<String, dynamic> composedPayload;
  final Map<String, dynamic> response;
  final String status;

  factory TestRunModel.fromJson(String id, Map<String, dynamic> json) {
    return TestRunModel(
      id: id,
      createdAt: dateTimeFromFirestore(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      adminUid: json['adminUid']?.toString() ?? '',
      inputPayload: mapFromDynamic(json['inputPayload']),
      composedPayload: mapFromDynamic(json['composedPayload']),
      response: mapFromDynamic(json['response']),
      status: json['status']?.toString() ?? 'ok',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'createdAt': dateTimeToIso(createdAt),
      'adminUid': adminUid,
      'inputPayload': inputPayload,
      'composedPayload': composedPayload,
      'response': response,
      'status': status,
    };
  }
}

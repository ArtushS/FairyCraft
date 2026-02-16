import '../../shared/firestore_utils.dart';

class GenerationLogModel {
  const GenerationLogModel({
    required this.id,
    required this.createdAt,
    required this.userIdHash,
    required this.tier,
    required this.language,
    required this.age,
    required this.requestSummary,
    required this.effectivePolicyId,
    required this.templateIdsUsed,
    required this.status,
    required this.provider,
    required this.latencyMs,
    this.errorCode,
    this.errorMessage,
  });

  final String id;
  final DateTime createdAt;
  final String userIdHash;
  final String tier;
  final String language;
  final int age;
  final Map<String, dynamic> requestSummary;
  final String effectivePolicyId;
  final List<String> templateIdsUsed;
  final String status;
  final String provider;
  final int latencyMs;
  final String? errorCode;
  final String? errorMessage;

  factory GenerationLogModel.fromJson(String id, Map<String, dynamic> json) {
    return GenerationLogModel(
      id: id,
      createdAt: dateTimeFromFirestore(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      userIdHash: json['userIdHash']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'free',
      language: json['language']?.toString() ?? 'en',
      age: (json['age'] as num?)?.toInt() ?? 6,
      requestSummary: mapFromDynamic(json['requestSummary']),
      effectivePolicyId: json['effectivePolicyId']?.toString() ?? '',
      templateIdsUsed: stringListFromDynamic(json['templateIdsUsed']),
      status: json['status']?.toString() ?? 'ok',
      provider: json['provider']?.toString() ?? 'mock',
      latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
      errorCode: json['errorCode']?.toString(),
      errorMessage: json['errorMessage']?.toString(),
    );
  }
}

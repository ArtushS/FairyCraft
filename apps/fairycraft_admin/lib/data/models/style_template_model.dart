import '../../shared/firestore_utils.dart';
import 'policy_scope.dart';

class TemplateBody {
  const TemplateBody({
    this.system,
    required this.instructions,
    this.negative,
  });

  final String? system;
  final String instructions;
  final String? negative;

  factory TemplateBody.fromJson(Map<String, dynamic> json) {
    return TemplateBody(
      system: json['system']?.toString(),
      instructions: json['instructions']?.toString() ?? '',
      negative: json['negative']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'system': system,
      'instructions': instructions,
      'negative': negative,
    };
  }

  TemplateBody copyWith({
    String? system,
    String? instructions,
    String? negative,
  }) {
    return TemplateBody(
      system: system ?? this.system,
      instructions: instructions ?? this.instructions,
      negative: negative ?? this.negative,
    );
  }
}

class StyleTemplateModel {
  const StyleTemplateModel({
    required this.id,
    required this.active,
    required this.type,
    required this.name,
    required this.description,
    required this.tags,
    required this.scopes,
    required this.template,
    this.updatedAt,
  });

  final String id;
  final bool active;
  final String type;
  final String name;
  final String description;
  final List<String> tags;
  final List<PolicyScope> scopes;
  final TemplateBody template;
  final DateTime? updatedAt;

  factory StyleTemplateModel.fromJson(String id, Map<String, dynamic> json) {
    return StyleTemplateModel(
      id: id,
      active: json['active'] as bool? ?? true,
      type: json['type']?.toString() ?? 'story',
      name: json['name']?.toString() ?? 'Untitled',
      description: json['description']?.toString() ?? '',
      tags: stringListFromDynamic(json['tags']),
      scopes: scopeListFromDynamic(json['scopes']),
      template: TemplateBody.fromJson(mapFromDynamic(json['template'])),
      updatedAt: dateTimeFromFirestore(json['updatedAt']),
    );
  }

  factory StyleTemplateModel.fallback({required String id}) {
    return StyleTemplateModel(
      id: id,
      active: true,
      type: 'story',
      name: 'New Template',
      description: '',
      tags: const <String>[],
      scopes: const <PolicyScope>[PolicyScope.global],
      template: const TemplateBody(
        instructions: 'Write a positive, age-appropriate interactive story.',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'active': active,
      'type': type,
      'name': name,
      'description': description,
      'tags': tags,
      'scopes': scopes.map((scope) => scope.toJson()).toList(growable: false),
      'template': template.toJson(),
      'updatedAt': dateTimeToIso(updatedAt),
    };
  }

  StyleTemplateModel copyWith({
    bool? active,
    String? type,
    String? name,
    String? description,
    List<String>? tags,
    List<PolicyScope>? scopes,
    TemplateBody? template,
    DateTime? updatedAt,
  }) {
    return StyleTemplateModel(
      id: id,
      active: active ?? this.active,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      scopes: scopes ?? this.scopes,
      template: template ?? this.template,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

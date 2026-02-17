import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

import '../../auth/admin_auth_controller.dart';
import '../../data/models/admin_policy_model.dart';
import '../../data/models/admin_test_input.dart';
import '../../data/models/style_template_model.dart';
import '../../data/models/test_run_model.dart';
import '../../data/repositories/effective_policy_resolver.dart';
import '../../data/repositories/policies_repository.dart';
import '../../data/repositories/templates_repository.dart';
import '../../data/repositories/test_runs_repository.dart';
import '../../data/services/admin_gateway_client.dart';

class TestConsolePage extends StatefulWidget {
  const TestConsolePage({super.key});

  @override
  State<TestConsolePage> createState() => _TestConsolePageState();
}

class _TestConsolePageState extends State<TestConsolePage> {
  final _ageController = TextEditingController(text: '8');
  final _storyIdeaController = TextEditingController(
    text: 'A little explorer discovers a hidden map in the attic.',
  );
  final _heroAgeController = TextEditingController(text: '8');
  final _locationController = TextEditingController(text: 'mountain village');
  final _genreController = TextEditingController(text: 'adventure');
  final _familyMembersController = TextEditingController(text: 'mom:1,dad:1');
  final _momNameController = TextEditingController();
  final _dadNameController = TextEditingController();
  final _grandmaNameController = TextEditingController();
  final _grandpaNameController = TextEditingController();
  final List<TextEditingController> _brotherNameControllers =
      <TextEditingController>[];
  final List<TextEditingController> _sisterNameControllers =
      <TextEditingController>[];

  String _tier = 'free';
  String _language = 'en';
  String _heroType = 'boy';
  String _length = 'short';
  String _complexity = 'simple';
  String _creativity = 'normal';
  bool _illustrationsEnabled = true;
  bool _safeMode = true;
  bool _disableScary = true;
  bool _requireParentConfirmationForOlder = true;

  bool _running = false;
  String? _error;
  AdminPolicyModel? _effectivePolicy;
  List<StyleTemplateModel> _effectiveTemplates = <StyleTemplateModel>[];
  Map<String, dynamic>? _composedPayload;
  Map<String, dynamic>? _gatewayResponse;

  @override
  void initState() {
    super.initState();
    _brotherNameControllers.add(TextEditingController());
    _sisterNameControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _ageController.dispose();
    _storyIdeaController.dispose();
    _heroAgeController.dispose();
    _locationController.dispose();
    _genreController.dispose();
    _familyMembersController.dispose();
    _momNameController.dispose();
    _dadNameController.dispose();
    _grandmaNameController.dispose();
    _grandpaNameController.dispose();
    _disposeNameControllers(_brotherNameControllers);
    _disposeNameControllers(_sisterNameControllers);
    super.dispose();
  }

  void _disposeNameControllers(List<TextEditingController> values) {
    for (final controller in values) {
      controller.dispose();
    }
    values.clear();
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
    });

    try {
      final policiesRepository = context.read<PoliciesRepository>();
      final templatesRepository = context.read<TemplatesRepository>();
      final resolver = context.read<EffectivePolicyResolver>();
      final gatewayClient = context.read<AdminGatewayClient>();
      final testRunsRepository = context.read<TestRunsRepository>();
      final authController = context.read<AdminAuthController>();

      final input = _buildInput();
      final policies = await policiesRepository.fetchAll();
      final templates = await templatesRepository.fetchAll();

      final resolution = resolver.resolve(
        policies: policies,
        templates: templates,
        age: input.age,
        language: input.language,
        tier: input.tier,
      );

      final dryRunResult = await gatewayClient.runDryRun(input);
      final gatewayBody = dryRunResult.body;

      final composedPayload = <String, dynamic>{
        'effectivePolicy': resolution.policy?.toJson(),
        'templateIds': resolution.templates
            .map((template) => template.id)
            .toList(growable: false),
        'gatewayComposedPayload': gatewayBody['composedPayload'],
        'gatewayDecision': gatewayBody['decision'],
      };

      final status = gatewayBody['decision'] is Map<String, dynamic>
          ? (gatewayBody['decision'] as Map<String, dynamic>)['status']
                    ?.toString() ??
                (dryRunResult.ok ? 'ok' : 'error')
          : (dryRunResult.ok ? 'ok' : 'error');

      final testRun = TestRunModel(
        id: testRunsRepository.createId(),
        createdAt: DateTime.now().toUtc(),
        adminUid: authController.currentUid ?? 'unknown',
        inputPayload: input.toJson(),
        composedPayload: composedPayload,
        response: gatewayBody,
        status: status,
      );
      await testRunsRepository.save(testRun);

      if (mounted) {
        setState(() {
          _effectivePolicy = resolution.policy;
          _effectiveTemplates = resolution.templates;
          _composedPayload = composedPayload;
          _gatewayResponse = gatewayBody;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _running = false;
        });
      }
    }
  }

  AdminTestInput _buildInput() {
    final familyNames = <String, String>{};
    void addFamilyName(String role, String value) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) {
        familyNames[role] = normalized;
      }
    }

    addFamilyName('mom', _momNameController.text);
    addFamilyName('dad', _dadNameController.text);
    addFamilyName('grandma', _grandmaNameController.text);
    addFamilyName('grandpa', _grandpaNameController.text);

    return AdminTestInput(
      age: int.tryParse(_ageController.text.trim()) ?? 8,
      tier: _tier,
      language: _language,
      storyIdea: _storyIdeaController.text.trim(),
      heroType: _heroType,
      heroAge: int.tryParse(_heroAgeController.text.trim()) ?? 8,
      location: _locationController.text.trim(),
      genre: _genreController.text.trim(),
      length: _length,
      complexity: _complexity,
      illustrationsEnabled: _illustrationsEnabled,
      familyMembers: _parseFamilyMembers(_familyMembersController.text),
      familyNames: familyNames,
      brothers: _collectNames(_brotherNameControllers),
      sisters: _collectNames(_sisterNameControllers),
      creativity: _creativity,
      safeMode: _safeMode,
      disableScaryContent: _disableScary,
      requireParentConfirmationForOlder: _requireParentConfirmationForOlder,
    );
  }

  List<String> _collectNames(List<TextEditingController> controllers) {
    return controllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, int> _parseFamilyMembers(String raw) {
    final entries = raw
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    final result = <String, int>{};
    for (final entry in entries) {
      final parts = entry.split(':');
      final key = parts.first.trim();
      final count = parts.length > 1 ? int.tryParse(parts[1].trim()) : 1;
      if (key.isNotEmpty) {
        result[key] = count ?? 1;
      }
    }
    return result;
  }

  void _addBrotherField() {
    setState(() {
      _brotherNameControllers.add(TextEditingController());
    });
  }

  void _addSisterField() {
    setState(() {
      _sisterNameControllers.add(TextEditingController());
    });
  }

  void _removeBrotherField(int index) {
    if (_brotherNameControllers.length <= 1) {
      _brotherNameControllers[index].clear();
      setState(() {});
      return;
    }
    setState(() {
      _brotherNameControllers.removeAt(index).dispose();
    });
  }

  void _removeSisterField(int index) {
    if (_sisterNameControllers.length <= 1) {
      _sisterNameControllers[index].clear();
      setState(() {});
      return;
    }
    setState(() {
      _sisterNameControllers.removeAt(index).dispose();
    });
  }

  Widget _nameListSection({
    required String title,
    required String labelPrefix,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...List<Widget>.generate(controllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: controllers[index],
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .tcIndexedName(
                                labelPrefix == 'brother'
                                    ? AppLocalizations.of(
                                        context,
                                      )!.tcBrotherLabel
                                    : AppLocalizations.of(
                                        context,
                                      )!.tcSisterLabel,
                                index + 1,
                              ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: AppLocalizations.of(context)!.tcRemoveTooltip,
                    ),
                  ],
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(
                labelPrefix == 'brother'
                    ? AppLocalizations.of(context)!.tcAddBrotherButton
                    : AppLocalizations.of(context)!.tcAddSisterButton,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.testConsoleTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(AppLocalizations.of(context)!.testConsoleDescription),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: 140,
              child: TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcAgeLabel,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: _tier,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcTierLabel,
                ),
                items: const <String>['free', 'pro', 'premium']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _tier = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcLanguageLabel,
                ),
                items: const <String>['en', 'ru', 'hy']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _language = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: _heroType,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcHeroTypeLabel,
                ),
                items: const <String>['boy', 'girl', 'dog', 'cat', 'custom']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _heroType = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _heroAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcHeroAgeLabel,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _storyIdeaController,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.tcStoryIdeaLabel,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: 220,
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcLocationLabel,
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _genreController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcGenreLabel,
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                initialValue: _length,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcLengthLabel,
                ),
                items: const <String>['short', 'medium', 'long']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _length = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                initialValue: _complexity,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcComplexityLabel,
                ),
                items: const <String>['simple', 'normal']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _complexity = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                initialValue: _creativity,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.tcCreativityLabel,
                ),
                items: const <String>['low', 'normal', 'high']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _creativity = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _familyMembersController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.tcFamilyMembersLabel,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.tcFamilyNamesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: <Widget>[
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _momNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.tcMomNameLabel,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _dadNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.tcDadNameLabel,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _grandmaNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.tcGrandmaNameLabel,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _grandpaNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.tcGrandpaNameLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _nameListSection(
          title: AppLocalizations.of(context)!.tcBrothersNamesTitle,
          labelPrefix: 'brother',
          controllers: _brotherNameControllers,
          onAdd: _addBrotherField,
          onRemove: _removeBrotherField,
        ),
        _nameListSection(
          title: AppLocalizations.of(context)!.tcSistersNamesTitle,
          labelPrefix: 'sister',
          controllers: _sisterNameControllers,
          onAdd: _addSisterField,
          onRemove: _removeSisterField,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            FilterChip(
              selected: _illustrationsEnabled,
              label: Text(AppLocalizations.of(context)!.tcIllustrationsEnabled),
              onSelected: (value) =>
                  setState(() => _illustrationsEnabled = value),
            ),
            FilterChip(
              selected: _safeMode,
              label: Text(AppLocalizations.of(context)!.tcSafeMode),
              onSelected: (value) => setState(() => _safeMode = value),
            ),
            FilterChip(
              selected: _disableScary,
              label: Text(AppLocalizations.of(context)!.tcDisableScary),
              onSelected: (value) => setState(() => _disableScary = value),
            ),
            FilterChip(
              selected: _requireParentConfirmationForOlder,
              label: Text(
                AppLocalizations.of(context)!.tcRequireParentConfirmation,
              ),
              onSelected: (value) =>
                  setState(() => _requireParentConfirmationForOlder = value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _running ? null : _run,
          icon: const Icon(Icons.play_arrow),
          label: _running
              ? Text(AppLocalizations.of(context)!.tcRunning)
              : Text(AppLocalizations.of(context)!.tcRunButton),
        ),
        if (_running) ...<Widget>[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        if (_effectivePolicy != null) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(
              context,
            )!.tcEffectivePolicyHeader(_effectivePolicy!.id),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            AppLocalizations.of(
              context,
            )!.tcTemplatesMatched(_effectiveTemplates.length),
          ),
          const SizedBox(height: 8),
          _jsonCard(
            title: AppLocalizations.of(context)!.tcCardEffectivePolicy,
            body: <String, dynamic>{
              'policy': _effectivePolicy!.toJson(),
              'templateIds': _effectiveTemplates
                  .map((template) => template.id)
                  .toList(growable: false),
            },
          ),
        ],
        if (_composedPayload != null) ...<Widget>[
          const SizedBox(height: 12),
          _jsonCard(
            title: AppLocalizations.of(context)!.tcCardComposedPayload,
            body: _sanitizeForDisplay(_composedPayload!),
          ),
        ],
        if (_gatewayResponse != null) ...<Widget>[
          const SizedBox(height: 12),
          _jsonCard(
            title: AppLocalizations.of(context)!.tcCardGatewayResponse,
            body: _sanitizeForDisplay(_gatewayResponse!),
          ),
        ],
      ],
    );
  }

  Widget _jsonCard({
    required String title,
    required Map<String, dynamic> body,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(JsonEncoder.withIndent('  ').convert(body)),
            ),
          ],
        ),
      ),
    );
  }

  // Sanitize a payload for display to avoid leaking personal names/PII.
  // This is intentionally conservative: any top-level keys that commonly
  // contain names are redacted. The raw payload is still stored in DB/test
  // runs, but UI surfaces should not show raw names.
  Map<String, dynamic> _sanitizeForDisplay(Map<String, dynamic> src) {
    Map<String, dynamic> clone = <String, dynamic>{};
    src.forEach((k, v) {
      if (k == 'familyNames' && v is Map<String, dynamic>) {
        clone[k] = v.map((key, value) => MapEntry(key, 'REDACTED'));
      } else if ((k == 'brothers' || k == 'sisters') && v is List) {
        // replace list of names with counts and redacted entries
        clone[k] = v.map((e) => 'REDACTED').toList(growable: false);
      } else if (v is Map<String, dynamic>) {
        clone[k] = _sanitizeForDisplay(v);
      } else if (v is List) {
        clone[k] = v
            .map((item) {
              if (item is Map<String, dynamic>) {
                return _sanitizeForDisplay(item);
              }
              return item;
            })
            .toList(growable: false);
      } else {
        clone[k] = v;
      }
    });
    return clone;
  }
}

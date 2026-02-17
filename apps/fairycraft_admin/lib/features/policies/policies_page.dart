import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../data/models/admin_policy_model.dart';
import '../../data/models/policy_scope.dart';
import '../../data/repositories/policies_repository.dart';

class PoliciesPage extends StatefulWidget {
  const PoliciesPage({super.key});

  @override
  State<PoliciesPage> createState() => _PoliciesPageState();
}

class _PoliciesPageState extends State<PoliciesPage> {
  bool _loading = true;
  bool _backfilling = false;
  String? _error;
  String? _maintenanceMessage;
  List<AdminPolicyModel> _policies = <AdminPolicyModel>[];
  String _languageFilter = '*';
  String _tierFilter = '*';
  RangeValues _ageFilter = const RangeValues(3, 12);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await context.read<PoliciesRepository>().fetchAll();
      if (mounted) {
        setState(() {
          _policies = items;
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
          _loading = false;
        });
      }
    }
  }

  Future<void> _createPolicy() async {
    final repository = context.read<PoliciesRepository>();
    final draft = AdminPolicyModel.fallback(
      id: repository.createId(),
    ).copyWith(versionStamp: DateTime.now().toUtc().toIso8601String());
    final result = await showDialog<AdminPolicyModel>(
      context: context,
      builder: (context) => _PolicyEditorDialog(policy: draft),
    );
    if (result == null) {
      return;
    }
    await repository.save(result);
    await _load();
  }

  Future<void> _editPolicy(AdminPolicyModel policy) async {
    final repository = context.read<PoliciesRepository>();
    final result = await showDialog<AdminPolicyModel>(
      context: context,
      builder: (context) => _PolicyEditorDialog(policy: policy),
    );
    if (result == null || !mounted) {
      return;
    }
    await repository.save(result);
    if (!mounted) {
      return;
    }
    await _load();
  }

  Future<void> _toggleActive(AdminPolicyModel policy, bool value) async {
    await context.read<PoliciesRepository>().save(
      policy.copyWith(
        active: value,
        versionStamp: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    await _load();
  }

  Future<void> _deletePolicy(AdminPolicyModel policy) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = context.read<PoliciesRepository>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.policiesDeletePolicyTitle),
        content: Text(l10n.policiesDeletePolicyConfirm(policy.id)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await repository.delete(policy.id);
    if (!mounted) {
      return;
    }
    await _load();
  }

  Future<void> _backfillAllowPersonalNames() async {
    setState(() {
      _backfilling = true;
      _maintenanceMessage = null;
    });

    try {
      final summary = await context
          .read<PoliciesRepository>()
          .backfillAllowPersonalNames();
      if (!mounted) {
        return;
      }
      setState(() {
        _maintenanceMessage =
            'Backfill completed. Scanned: ${summary.scanned}, '
            'updated: ${summary.updated}, skipped: ${summary.skipped}.';
      });
      await _load();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _maintenanceMessage = 'Backfill failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _backfilling = false;
        });
      }
    }
  }

  List<AdminPolicyModel> get _filteredPolicies {
    return _policies
        .where((policy) {
          final languageMatches =
              _languageFilter == '*' ||
              policy.scope.language == _languageFilter;
          final tierMatches =
              _tierFilter == '*' || policy.scope.tier == _tierFilter;
          final ageRangeOverlaps =
              policy.scope.ageMax >= _ageFilter.start &&
              policy.scope.ageMin <= _ageFilter.end;
          return languageMatches && tierMatches && ageRangeOverlaps;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: _languageFilter,
              items: const <String>['*', 'en', 'ru', 'hy']
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.policiesLanguageFilterLabel(value),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _languageFilter = value;
                });
              },
            ),
            DropdownButton<String>(
              value: _tierFilter,
              items: const <String>['*', 'free', 'pro', 'premium']
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.policiesTierFilterLabel(value),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _tierFilter = value;
                });
              },
            ),
            Text(AppLocalizations.of(context)!.policiesAgeRangeFilter),
            SizedBox(
              width: 240,
              child: RangeSlider(
                min: 3,
                max: 12,
                divisions: 9,
                labels: RangeLabels(
                  _ageFilter.start.round().toString(),
                  _ageFilter.end.round().toString(),
                ),
                values: _ageFilter,
                onChanged: (values) {
                  setState(() {
                    _ageFilter = values;
                  });
                },
              ),
            ),
            FilledButton.icon(
              onPressed: _createPolicy,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.policiesNewPolicy),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.commonReload),
            ),
            FilledButton.tonalIcon(
              onPressed: _backfilling ? null : _backfillAllowPersonalNames,
              icon: _backfilling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.build_circle_outlined),
              label: Text(
                _backfilling
                    ? AppLocalizations.of(context)!.policiesBackfillInProgress
                    : AppLocalizations.of(context)!.policiesBackfillButton,
              ),
            ),
          ],
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        if (_maintenanceMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_maintenanceMessage!),
        ],
        const SizedBox(height: 16),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.policiesColumnActive,
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.policiesColumnPolicyId,
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.policiesColumnScope,
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.policiesColumnReadingLevel,
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.policiesColumnVersionStamp,
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)!.policiesColumnActions,
                  ),
                ),
              ],
              rows: _filteredPolicies
                  .map(
                    (policy) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Switch(
                            value: policy.active,
                            onChanged: (value) => _toggleActive(policy, value),
                          ),
                        ),
                        DataCell(SelectableText(policy.id)),
                        DataCell(Text(policy.scope.displayLabel())),
                        DataCell(Text(policy.promptConstraints.readingLevel)),
                        DataCell(Text(policy.versionStamp)),
                        DataCell(
                          Wrap(
                            spacing: 8,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: () => _editPolicy(policy),
                                child: Text(
                                  AppLocalizations.of(context)!.commonEdit,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _deletePolicy(policy),
                                child: Text(
                                  AppLocalizations.of(context)!.commonDelete,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyEditorDialog extends StatefulWidget {
  const _PolicyEditorDialog({required this.policy});

  final AdminPolicyModel policy;

  @override
  State<_PolicyEditorDialog> createState() => _PolicyEditorDialogState();
}

class _PolicyEditorDialogState extends State<_PolicyEditorDialog> {
  late final TextEditingController _ageMinController;
  late final TextEditingController _ageMaxController;
  late final TextEditingController _languageController;
  late final TextEditingController _tierController;
  late final TextEditingController _maxTokensController;
  late final TextEditingController _maxCharsController;
  late final TextEditingController _readingLevelController;
  late final TextEditingController _bannedWordsController;
  late final TextEditingController _imageStylesController;
  late final TextEditingController _versionStampController;

  late bool _active;
  late bool _safeModeDefault;
  late bool _disallowViolence;
  late bool _disallowDrugs;
  late bool _disallowHate;
  late bool _disallowSexualContent;
  late bool _disallowReligiousPolitical;
  late bool _requireParentConfirmationForOlder;
  late bool _disallowScary;
  late bool _allowPersonalNames;
  late bool _allowImages;
  late bool _enforceStructure;

  @override
  void initState() {
    super.initState();
    final policy = widget.policy;
    _ageMinController = TextEditingController(
      text: policy.scope.ageMin.toString(),
    );
    _ageMaxController = TextEditingController(
      text: policy.scope.ageMax.toString(),
    );
    _languageController = TextEditingController(text: policy.scope.language);
    _tierController = TextEditingController(text: policy.scope.tier);
    _maxTokensController = TextEditingController(
      text: policy.promptConstraints.maxTokensHint.toString(),
    );
    _maxCharsController = TextEditingController(
      text: policy.promptConstraints.maxCharsHint.toString(),
    );
    _readingLevelController = TextEditingController(
      text: policy.promptConstraints.readingLevel,
    );
    _bannedWordsController = TextEditingController(
      text: policy.contentRules.customBannedWords.join(', '),
    );
    _imageStylesController = TextEditingController(
      text: policy.imageRules.allowedImageStyles.join(', '),
    );
    _versionStampController = TextEditingController(text: policy.versionStamp);

    _active = policy.active;
    _safeModeDefault = policy.contentRules.safeModeDefault;
    _disallowViolence = policy.contentRules.disallowViolence;
    _disallowDrugs = policy.contentRules.disallowDrugs;
    _disallowHate = policy.contentRules.disallowHate;
    _disallowSexualContent = policy.contentRules.disallowSexualContent;
    _disallowReligiousPolitical =
        policy.contentRules.disallowReligiousPolitical;
    _requireParentConfirmationForOlder =
        policy.contentRules.requireParentConfirmationForOlder;
    _disallowScary = policy.contentRules.disallowScary;
    _allowPersonalNames = policy.contentRules.allowPersonalNames;
    _allowImages = policy.imageRules.allowImages;
    _enforceStructure = policy.promptConstraints.enforceStructure;
  }

  @override
  void dispose() {
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _languageController.dispose();
    _tierController.dispose();
    _maxTokensController.dispose();
    _maxCharsController.dispose();
    _readingLevelController.dispose();
    _bannedWordsController.dispose();
    _imageStylesController.dispose();
    _versionStampController.dispose();
    super.dispose();
  }

  void _save() {
    final ageMin = int.tryParse(_ageMinController.text.trim()) ?? 3;
    final ageMax = int.tryParse(_ageMaxController.text.trim()) ?? 12;
    final maxTokens = int.tryParse(_maxTokensController.text.trim()) ?? 700;
    final maxChars = int.tryParse(_maxCharsController.text.trim()) ?? 4500;
    final readingLevel = _readingLevelController.text.trim().isEmpty
        ? 'simple'
        : _readingLevelController.text.trim();
    final bannedWords = _bannedWordsController.text
        .split(RegExp(r'[,\n]'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    final imageStyles = _imageStylesController.text
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final versionStamp = _versionStampController.text.trim().isEmpty
        ? DateTime.now().toUtc().toIso8601String()
        : _versionStampController.text.trim();

    Navigator.of(context).pop(
      widget.policy.copyWith(
        active: _active,
        scope: PolicyScope(
          ageMin: ageMin,
          ageMax: ageMax,
          language: _languageController.text.trim().isEmpty
              ? '*'
              : _languageController.text.trim(),
          tier: _tierController.text.trim().isEmpty
              ? '*'
              : _tierController.text.trim(),
        ),
        contentRules: widget.policy.contentRules.copyWith(
          safeModeDefault: _safeModeDefault,
          disallowViolence: _disallowViolence,
          disallowDrugs: _disallowDrugs,
          disallowHate: _disallowHate,
          disallowSexualContent: _disallowSexualContent,
          disallowReligiousPolitical: _disallowReligiousPolitical,
          requireParentConfirmationForOlder: _requireParentConfirmationForOlder,
          disallowScary: _disallowScary,
          allowPersonalNames: _allowPersonalNames,
          customBannedWords: bannedWords,
        ),
        promptConstraints: widget.policy.promptConstraints.copyWith(
          maxTokensHint: maxTokens,
          maxCharsHint: maxChars,
          enforceStructure: _enforceStructure,
          readingLevel: readingLevel,
        ),
        imageRules: widget.policy.imageRules.copyWith(
          allowImages: _allowImages,
          allowedImageStyles: imageStyles,
        ),
        versionStamp: versionStamp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Policy: ${widget.policy.id}'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SwitchListTile(
                title: const Text('Active'),
                value: _active,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Scope', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _ageMinController,
                      decoration: const InputDecoration(labelText: 'Age Min'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ageMaxController,
                      decoration: const InputDecoration(labelText: 'Age Max'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _languageController,
                      decoration: const InputDecoration(
                        labelText: 'Language (en|ru|hy|*)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tierController,
                      decoration: const InputDecoration(
                        labelText: 'Tier (free|pro|premium|*)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Content Rules',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _booleanChip(
                    'Safe mode default',
                    _safeModeDefault,
                    (value) => setState(() => _safeModeDefault = value),
                  ),
                  _booleanChip(
                    'Disallow violence',
                    _disallowViolence,
                    (value) => setState(() => _disallowViolence = value),
                  ),
                  _booleanChip(
                    'Disallow drugs',
                    _disallowDrugs,
                    (value) => setState(() => _disallowDrugs = value),
                  ),
                  _booleanChip(
                    'Disallow hate',
                    _disallowHate,
                    (value) => setState(() => _disallowHate = value),
                  ),
                  _booleanChip(
                    'Disallow sexual content',
                    _disallowSexualContent,
                    (value) => setState(() => _disallowSexualContent = value),
                  ),
                  _booleanChip(
                    'Disallow religious/political',
                    _disallowReligiousPolitical,
                    (value) =>
                        setState(() => _disallowReligiousPolitical = value),
                  ),
                  _booleanChip(
                    'Parent confirmation for older',
                    _requireParentConfirmationForOlder,
                    (value) => setState(
                      () => _requireParentConfirmationForOlder = value,
                    ),
                  ),
                  _booleanChip(
                    'Disallow scary content',
                    _disallowScary,
                    (value) => setState(() => _disallowScary = value),
                  ),
                  _booleanChip(
                    'Allow personal names',
                    _allowPersonalNames,
                    (value) => setState(() => _allowPersonalNames = value),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bannedWordsController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Custom banned words (comma/newline separated)',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Prompt Constraints',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _maxTokensController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max tokens hint',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxCharsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max chars hint',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _readingLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Reading level (simple|normal)',
                      ),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Enforce structure'),
                value: _enforceStructure,
                onChanged: (value) {
                  setState(() {
                    _enforceStructure = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Image Rules',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SwitchListTile(
                title: const Text('Allow images'),
                value: _allowImages,
                onChanged: (value) {
                  setState(() {
                    _allowImages = value;
                  });
                },
              ),
              TextField(
                controller: _imageStylesController,
                decoration: const InputDecoration(
                  labelText: 'Allowed image styles (comma/newline separated)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _versionStampController,
                decoration: const InputDecoration(labelText: 'Version stamp'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _booleanChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      selected: value,
      label: Text(label),
      onSelected: onChanged,
    );
  }
}

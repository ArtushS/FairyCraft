import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/policy_scope.dart';
import '../../data/models/style_template_model.dart';
import '../../data/repositories/templates_repository.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  bool _loading = true;
  String? _error;
  List<StyleTemplateModel> _templates = <StyleTemplateModel>[];
  String _search = '';
  String _typeFilter = '*';

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
      final items = await context.read<TemplatesRepository>().fetchAll();
      if (mounted) {
        setState(() {
          _templates = items;
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

  Future<void> _createTemplate() async {
    final repository = context.read<TemplatesRepository>();
    final draft = StyleTemplateModel.fallback(id: repository.createId());
    final result = await showDialog<StyleTemplateModel>(
      context: context,
      builder: (context) => _TemplateEditorDialog(template: draft),
    );
    if (result == null) {
      return;
    }
    await repository.save(result);
    await _load();
  }

  Future<void> _editTemplate(StyleTemplateModel template) async {
    final repository = context.read<TemplatesRepository>();
    final result = await showDialog<StyleTemplateModel>(
      context: context,
      builder: (context) => _TemplateEditorDialog(template: template),
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

  Future<void> _toggleActive(StyleTemplateModel template, bool value) async {
    await context
        .read<TemplatesRepository>()
        .save(template.copyWith(active: value));
    await _load();
  }

  Future<void> _deleteTemplate(StyleTemplateModel template) async {
    final repository = context.read<TemplatesRepository>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Template'),
        content: Text(
          'Delete template "${template.name}"? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }
    await repository.delete(template.id);
    if (!mounted) {
      return;
    }
    await _load();
  }

  List<StyleTemplateModel> get _filteredTemplates {
    return _templates.where((template) {
      final search = _search.trim().toLowerCase();
      final matchesSearch = search.isEmpty ||
          template.name.toLowerCase().contains(search) ||
          template.description.toLowerCase().contains(search) ||
          template.tags.any((tag) => tag.toLowerCase().contains(search));
      final typeMatches = _typeFilter == '*' || template.type == _typeFilter;
      return matchesSearch && typeMatches;
    }).toList(growable: false);
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
          children: <Widget>[
            SizedBox(
              width: 280,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by name/tag/description',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
              ),
            ),
            DropdownButton<String>(
              value: _typeFilter,
              items: const <String>['*', 'story', 'image']
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text('Type: $type'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _typeFilter = value;
                });
              },
            ),
            FilledButton.icon(
              onPressed: _createTemplate,
              icon: const Icon(Icons.add),
              label: const Text('New Template'),
            ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
        const SizedBox(height: 16),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Active')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Tags')),
                DataColumn(label: Text('Scopes')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _filteredTemplates
                  .map(
                    (template) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Switch(
                            value: template.active,
                            onChanged: (value) => _toggleActive(template, value),
                          ),
                        ),
                        DataCell(
                          Text(
                            template.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(Text(template.type)),
                        DataCell(Text(template.tags.join(', '))),
                        DataCell(Text(template.scopes.length.toString())),
                        DataCell(
                          Wrap(
                            spacing: 8,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: () => _editTemplate(template),
                                child: const Text('Edit'),
                              ),
                              TextButton(
                                onPressed: () => _deleteTemplate(template),
                                child: const Text('Delete'),
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

class _TemplateEditorDialog extends StatefulWidget {
  const _TemplateEditorDialog({required this.template});

  final StyleTemplateModel template;

  @override
  State<_TemplateEditorDialog> createState() => _TemplateEditorDialogState();
}

class _TemplateEditorDialogState extends State<_TemplateEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late final TextEditingController _systemController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _negativeController;

  late bool _active;
  late String _type;
  late List<PolicyScope> _scopes;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _active = template.active;
    _type = template.type;
    _scopes = List<PolicyScope>.from(template.scopes);
    _nameController = TextEditingController(text: template.name);
    _descriptionController = TextEditingController(text: template.description);
    _tagsController = TextEditingController(text: template.tags.join(', '));
    _systemController = TextEditingController(text: template.template.system);
    _instructionsController = TextEditingController(
      text: template.template.instructions,
    );
    _negativeController = TextEditingController(text: template.template.negative);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _systemController.dispose();
    _instructionsController.dispose();
    _negativeController.dispose();
    super.dispose();
  }

  void _addScope() {
    setState(() {
      _scopes = <PolicyScope>[
        ..._scopes,
        const PolicyScope(ageMin: 6, ageMax: 12, language: '*', tier: '*'),
      ];
    });
  }

  void _updateScope(int index, PolicyScope scope) {
    setState(() {
      final next = List<PolicyScope>.from(_scopes);
      next[index] = scope;
      _scopes = next;
    });
  }

  void _removeScope(int index) {
    if (_scopes.length <= 1) {
      return;
    }
    setState(() {
      final next = List<PolicyScope>.from(_scopes);
      next.removeAt(index);
      _scopes = next;
    });
  }

  void _save() {
    final tags = _tagsController.text
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final updated = widget.template.copyWith(
      active: _active,
      type: _type,
      name: _nameController.text.trim().isEmpty
          ? 'Untitled'
          : _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      tags: tags,
      scopes: _scopes,
      template: widget.template.template.copyWith(
        system: _systemController.text.trim().isEmpty
            ? null
            : _systemController.text.trim(),
        instructions: _instructionsController.text.trim(),
        negative: _negativeController.text.trim().isEmpty
            ? null
            : _negativeController.text.trim(),
      ),
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Template: ${widget.template.id}'),
      content: SizedBox(
        width: 820,
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
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Template type'),
                items: const <String>['story', 'image']
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _type = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma/newline separated)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Scopes',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: _addScope,
                    icon: const Icon(Icons.add),
                    label: const Text('Add scope'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List<Widget>.generate(
                _scopes.length,
                (index) => _ScopeRow(
                  scope: _scopes[index],
                  onChanged: (scope) => _updateScope(index, scope),
                  onDelete: () => _removeScope(index),
                  canDelete: _scopes.length > 1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Template Body',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _systemController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'System prompt (optional)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _instructionsController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _negativeController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Negative prompt (optional)',
                ),
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
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ScopeRow extends StatefulWidget {
  const _ScopeRow({
    required this.scope,
    required this.onChanged,
    required this.onDelete,
    required this.canDelete,
  });

  final PolicyScope scope;
  final ValueChanged<PolicyScope> onChanged;
  final VoidCallback onDelete;
  final bool canDelete;

  @override
  State<_ScopeRow> createState() => _ScopeRowState();
}

class _ScopeRowState extends State<_ScopeRow> {
  late final TextEditingController _ageMinController;
  late final TextEditingController _ageMaxController;
  late final TextEditingController _languageController;
  late final TextEditingController _tierController;

  @override
  void initState() {
    super.initState();
    _ageMinController = TextEditingController(
      text: widget.scope.ageMin.toString(),
    );
    _ageMaxController = TextEditingController(
      text: widget.scope.ageMax.toString(),
    );
    _languageController = TextEditingController(text: widget.scope.language);
    _tierController = TextEditingController(text: widget.scope.tier);
  }

  @override
  void dispose() {
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _languageController.dispose();
    _tierController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      PolicyScope(
        ageMin: int.tryParse(_ageMinController.text.trim()) ?? 6,
        ageMax: int.tryParse(_ageMaxController.text.trim()) ?? 12,
        language: _languageController.text.trim().isEmpty
            ? '*'
            : _languageController.text.trim(),
        tier:
            _tierController.text.trim().isEmpty ? '*' : _tierController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _ageMinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age min'),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ageMaxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age max'),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _languageController,
                decoration: const InputDecoration(labelText: 'Language'),
                onChanged: (_) => _emit(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _tierController,
                decoration: const InputDecoration(labelText: 'Tier'),
                onChanged: (_) => _emit(),
              ),
            ),
            IconButton(
              onPressed: widget.canDelete ? widget.onDelete : null,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

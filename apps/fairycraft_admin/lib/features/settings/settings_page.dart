import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/admin_config_model.dart';
import '../../data/repositories/admin_config_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  String? _error;
  AdminConfigModel _config = AdminConfigModel.fallback;

  late final TextEditingController _supportedLanguagesController;
  late final TextEditingController _primaryProviderController;
  late final TextEditingController _gptModelController;
  late final TextEditingController _vertexModelController;
  late final TextEditingController _providerNoteController;

  late String _defaultLanguage;
  late bool _safeModeDefault;
  late bool _strictSafeModeDefault;
  late bool _disallowScaryDefault;
  late bool _allowImagesByDefault;

  @override
  void initState() {
    super.initState();
    _supportedLanguagesController = TextEditingController();
    _primaryProviderController = TextEditingController();
    _gptModelController = TextEditingController();
    _vertexModelController = TextEditingController();
    _providerNoteController = TextEditingController();
    _hydrateFromConfig(_config);
    _load();
  }

  void _hydrateFromConfig(AdminConfigModel config) {
    _config = config;
    _defaultLanguage = config.defaultLanguage;
    _safeModeDefault = config.safeDefaults['safeModeDefault'] == true;
    _strictSafeModeDefault = config.safeDefaults['strictSafeModeDefault'] == true;
    _disallowScaryDefault = config.safeDefaults['disallowScaryDefault'] == true;
    _allowImagesByDefault = config.safeDefaults['allowImagesByDefault'] == true;
    _supportedLanguagesController.text = config.supportedLanguages.join(', ');
    _primaryProviderController.text =
        config.providerPlaceholders['primaryProvider']?.toString() ?? '';
    _gptModelController.text =
        config.providerPlaceholders['gptModel']?.toString() ?? '';
    _vertexModelController.text =
        config.providerPlaceholders['vertexModel']?.toString() ?? '';
    _providerNoteController.text =
        config.providerPlaceholders['note']?.toString() ?? '';
  }

  @override
  void dispose() {
    _supportedLanguagesController.dispose();
    _primaryProviderController.dispose();
    _gptModelController.dispose();
    _vertexModelController.dispose();
    _providerNoteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final config = await context.read<AdminConfigRepository>().load();
      if (mounted) {
        setState(() {
          _hydrateFromConfig(config);
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

  Future<void> _save() async {
    final supportedLanguages = _supportedLanguagesController.text
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final defaultLanguage = supportedLanguages.contains(_defaultLanguage)
        ? _defaultLanguage
        : (supportedLanguages.isEmpty ? 'en' : supportedLanguages.first);

    final next = _config.copyWith(
      defaultLanguage: defaultLanguage,
      supportedLanguages: supportedLanguages.isEmpty
          ? const <String>['en', 'ru', 'hy']
          : supportedLanguages,
      safeDefaults: <String, dynamic>{
        'safeModeDefault': _safeModeDefault,
        'strictSafeModeDefault': _strictSafeModeDefault,
        'disallowScaryDefault': _disallowScaryDefault,
        'allowImagesByDefault': _allowImagesByDefault,
      },
      providerPlaceholders: <String, dynamic>{
        'primaryProvider': _primaryProviderController.text.trim(),
        'gptModel': _gptModelController.text.trim(),
        'vertexModel': _vertexModelController.text.trim(),
        'note': _providerNoteController.text.trim(),
      },
      updatedAt: DateTime.now().toUtc(),
    );

    await context.read<AdminConfigRepository>().save(next);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final supportedOptions = _supportedLanguagesController.text
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (!supportedOptions.contains(_defaultLanguage)) {
      supportedOptions.insert(0, _defaultLanguage);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'System Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Global Language Defaults',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _supportedLanguagesController,
                  decoration: const InputDecoration(
                    labelText: 'Supported languages (comma separated)',
                    hintText: 'en, ru, hy',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _defaultLanguage,
                  decoration:
                      const InputDecoration(labelText: 'Default language'),
                  items: supportedOptions
                      .map(
                        (language) => DropdownMenuItem<String>(
                          value: language,
                          child: Text(language),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _defaultLanguage = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Safe Defaults',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Safe mode default'),
                  value: _safeModeDefault,
                  onChanged: (value) => setState(() => _safeModeDefault = value),
                ),
                SwitchListTile(
                  title: const Text('Strict safe mode default'),
                  value: _strictSafeModeDefault,
                  onChanged: (value) =>
                      setState(() => _strictSafeModeDefault = value),
                ),
                SwitchListTile(
                  title: const Text('Disallow scary content by default'),
                  value: _disallowScaryDefault,
                  onChanged: (value) =>
                      setState(() => _disallowScaryDefault = value),
                ),
                SwitchListTile(
                  title: const Text('Allow images by default'),
                  value: _allowImagesByDefault,
                  onChanged: (value) =>
                      setState(() => _allowImagesByDefault = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Provider Configuration Placeholders',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Secrets must stay in environment variables and never in Firestore plaintext.',
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _primaryProviderController,
                  decoration:
                      const InputDecoration(labelText: 'Primary provider'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _gptModelController,
                  decoration:
                      const InputDecoration(labelText: 'GPT model placeholder'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _vertexModelController,
                  decoration: const InputDecoration(
                    labelText: 'Vertex model placeholder',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _providerNoteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Ops note'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save settings'),
          ),
        ),
      ],
    );
  }
}

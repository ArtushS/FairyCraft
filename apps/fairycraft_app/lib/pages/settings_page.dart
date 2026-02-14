import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../settings/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          DropdownButtonFormField<ThemeMode>(
            initialValue: settings.themeMode,
            decoration: const InputDecoration(labelText: 'Theme mode'),
            items: ThemeMode.values
                .map(
                  (mode) => DropdownMenuItem<ThemeMode>(
                    value: mode,
                    child: Text(mode.name),
                  ),
                )
                .toList(growable: false),
            onChanged: (mode) {
              if (mode != null) {
                settings.setThemeMode(mode);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: settings.defaultLanguageCode,
            decoration: const InputDecoration(labelText: 'Default language'),
            items: const <String>['en', 'ru', 'hy']
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                settings.setDefaultLanguageCode(value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<FontScale>(
            initialValue: settings.fontScale,
            decoration: const InputDecoration(labelText: 'Font scale'),
            items: FontScale.values
                .map(
                  (value) => DropdownMenuItem<FontScale>(
                    value: value,
                    child: Text(value.name),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                settings.setFontScale(value);
              }
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: settings.onboardingCompleted,
            title: const Text('Onboarding completed'),
            onChanged: (value) => settings.setOnboardingCompleted(value),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/voice-help'),
            child: const Text('Open voice help'),
          ),
        ],
      ),
    );
  }
}



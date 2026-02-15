import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../settings/settings_controller.dart';
import '../../../shared/ui/fairycraft_theme.dart';
import 'settings_strings.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = SettingsStrings.of(context);
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(strings.languageScreenTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: FairyCraftSpacing.page,
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(strings.languageEnglish),
                    trailing: settings.localeCode == 'en'
                        ? const Icon(Icons.check_circle_rounded)
                        : null,
                    onTap: () async {
                      await settings.setLocaleCode('en');
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(strings.languageRussian),
                    trailing: settings.localeCode == 'ru'
                        ? const Icon(Icons.check_circle_rounded)
                        : null,
                    onTap: () async {
                      await settings.setLocaleCode('ru');
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(strings.languageArmenian),
                    trailing: settings.localeCode == 'hy'
                        ? const Icon(Icons.check_circle_rounded)
                        : null,
                    onTap: () async {
                      await settings.setLocaleCode('hy');
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui/fairycraft_theme.dart';
import 'settings_strings.dart';

class VoiceInputHelpScreen extends StatelessWidget {
  const VoiceInputHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = SettingsStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(strings.voiceHelpScreenTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: FairyCraftSpacing.page,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(FairyCraftSpacing.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      strings.voiceHelpDescription,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: FairyCraftSpacing.section),
                    _HelpItem(text: strings.voiceHelpPointOne),
                    const SizedBox(height: FairyCraftSpacing.element),
                    _HelpItem(text: strings.voiceHelpPointTwo),
                    const SizedBox(height: FairyCraftSpacing.element),
                    _HelpItem(text: strings.voiceHelpPointThree),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 20,
            color: FairyCraftPalette.secondary,
          ),
        ),
        const SizedBox(width: FairyCraftSpacing.element),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

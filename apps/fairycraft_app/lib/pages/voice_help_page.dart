import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../voice/voice_input_controller.dart';

class VoiceHelpPage extends StatelessWidget {
  const VoiceHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final voice = context.watch<VoiceInputController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.voiceHelpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.voiceHelpDescription),
            const SizedBox(height: 12),
            Text(l10n.voiceHelpListening(voice.isListening.toString())),
            Text(
              l10n.voiceHelpLastText(
                voice.lastText.isEmpty ? '-' : voice.lastText,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: voice.isListening ? null : voice.startListening,
                  child: Text(l10n.voiceHelpStartListening),
                ),
                OutlinedButton(
                  onPressed: voice.isListening ? voice.stopListening : null,
                  child: Text(l10n.voiceHelpStop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

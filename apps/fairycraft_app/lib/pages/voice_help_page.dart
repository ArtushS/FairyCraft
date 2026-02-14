import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../voice/voice_input_controller.dart';

class VoiceHelpPage extends StatelessWidget {
  const VoiceHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceInputController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Voice help')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Use microphone to capture ideas for story setup or prompts.'),
            const SizedBox(height: 12),
            Text('Listening: ${voice.isListening}'),
            Text('Last text: ${voice.lastText.isEmpty ? '-' : voice.lastText}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton(
                  onPressed: voice.isListening ? null : voice.startListening,
                  child: const Text('Start listening'),
                ),
                OutlinedButton(
                  onPressed: voice.isListening ? voice.stopListening : null,
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

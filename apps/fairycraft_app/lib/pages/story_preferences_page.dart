import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../shared/ui/fairycraft_theme.dart';
import '../story/story_preferences_controller.dart';

class StoryPreferencesPage extends StatefulWidget {
  const StoryPreferencesPage({super.key});

  @override
  State<StoryPreferencesPage> createState() => _StoryPreferencesPageState();
}

class _StoryPreferencesPageState extends State<StoryPreferencesPage> {
  late final TextEditingController _heroNameController;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<StoryPreferencesController>();
    _heroNameController = TextEditingController(text: prefs.heroName);
  }

  @override
  void dispose() {
    _heroNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prefs = context.watch<StoryPreferencesController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storyPreferencesTitle)),
      body: ListView(
        padding: FairyCraftSpacing.page,
        children: <Widget>[
          Text(
            l10n.storyPreferencesCreativeControlTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: FairyCraftSpacing.element),
          Text(
            l10n.storyPreferencesCreativeControlDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesCharacterSection,
            child: TextField(
              controller: _heroNameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.storyPreferencesHeroNameLabel,
                hintText: l10n.storyPreferencesHeroNameHint,
              ),
              onChanged: (value) {
                prefs.setHeroName(value);
              },
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesAgeSection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.storyPreferencesAgeYears(prefs.targetAge),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  min: 3,
                  max: 12,
                  divisions: 9,
                  value: prefs.targetAge.toDouble(),
                  onChanged: (value) {
                    prefs.setTargetAge(value.round());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesLengthSection,
            child: _SegmentedButtons<StoryLengthPreference>(
              selected: prefs.storyLength,
              options: <_SegmentOption<StoryLengthPreference>>[
                _SegmentOption(
                  value: StoryLengthPreference.short,
                  label: l10n.storyPreferencesLengthShort,
                ),
                _SegmentOption(
                  value: StoryLengthPreference.medium,
                  label: l10n.storyPreferencesLengthMedium,
                ),
                _SegmentOption(
                  value: StoryLengthPreference.long,
                  label: l10n.storyPreferencesLengthLong,
                ),
              ],
              onSelected: prefs.setStoryLength,
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesComplexitySection,
            child: _SegmentedButtons<StoryComplexityPreference>(
              selected: prefs.storyComplexity,
              options: <_SegmentOption<StoryComplexityPreference>>[
                _SegmentOption(
                  value: StoryComplexityPreference.simple,
                  label: l10n.storyPreferencesComplexitySimple,
                ),
                _SegmentOption(
                  value: StoryComplexityPreference.medium,
                  label: l10n.storyPreferencesComplexityMedium,
                ),
                _SegmentOption(
                  value: StoryComplexityPreference.complex,
                  label: l10n.storyPreferencesComplexityComplex,
                ),
              ],
              onSelected: prefs.setStoryComplexity,
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesInteractivitySection,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: prefs.interactiveChoices,
              title: Text(l10n.storyPreferencesInteractiveChoices),
              onChanged: prefs.setInteractiveChoices,
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesFamilySection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: prefs.familyMode,
                  title: Text(l10n.storyPreferencesIncludeFamilyMembers),
                  onChanged: prefs.setFamilyMode,
                ),
                const SizedBox(height: FairyCraftSpacing.element),
                Wrap(
                  spacing: FairyCraftSpacing.element,
                  runSpacing: FairyCraftSpacing.element,
                  children: StoryPreferencesController.familyMemberIds
                      .map((memberId) {
                        final selected = prefs.familyMembers.contains(memberId);
                        return FilterChip(
                          selected: selected,
                          label: Text(_familyLabel(l10n, memberId)),
                          onSelected: prefs.familyMode
                              ? (isSelected) {
                                  final next = List<String>.from(
                                    prefs.familyMembers,
                                  );
                                  if (isSelected) {
                                    if (!next.contains(memberId)) {
                                      next.add(memberId);
                                    }
                                  } else {
                                    next.remove(memberId);
                                  }
                                  prefs.setFamilyMembers(next);
                                }
                              : null,
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesIllustrationsSection,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: prefs.autoIllustrations,
              title: Text(l10n.storyPreferencesAddIllustrations),
              onChanged: prefs.setAutoIllustrations,
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          _SectionCard(
            title: l10n.storyPreferencesCreativitySection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.storyPreferencesCreativityPercent(
                    (prefs.creativity * 100).round(),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  min: 0,
                  max: 1,
                  divisions: 10,
                  value: prefs.creativity,
                  onChanged: prefs.setCreativity,
                ),
              ],
            ),
          ),
          const SizedBox(height: FairyCraftSpacing.section),
          OutlinedButton.icon(
            onPressed: prefs.resetToDefaults,
            icon: const Icon(Icons.restart_alt),
            label: Text(l10n.storyPreferencesResetButton),
          ),
        ],
      ),
    );
  }

  String _familyLabel(AppLocalizations l10n, String memberId) {
    switch (memberId) {
      case StoryPreferencesController.memberMom:
        return l10n.familyMom;
      case StoryPreferencesController.memberDad:
        return l10n.familyDad;
      case StoryPreferencesController.memberSister:
        return l10n.familySister;
      case StoryPreferencesController.memberBrother:
        return l10n.familyBrother;
      case StoryPreferencesController.memberGrandma:
        return l10n.familyGrandma;
      case StoryPreferencesController.memberGrandpa:
        return l10n.familyGrandpa;
      default:
        return memberId;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(FairyCraftSpacing.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: FairyCraftSpacing.element),
            child,
          ],
        ),
      ),
    );
  }
}

class _SegmentOption<T> {
  const _SegmentOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _SegmentedButtons<T> extends StatelessWidget {
  const _SegmentedButtons({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final T selected;
  final List<_SegmentOption<T>> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: FairyCraftSpacing.element,
      runSpacing: FairyCraftSpacing.element,
      children: options
          .map((option) {
            final isActive = option.value == selected;
            return ChoiceChip(
              selected: isActive,
              label: Text(option.label),
              onSelected: (_) => onSelected(option.value),
            );
          })
          .toList(growable: false),
    );
  }
}

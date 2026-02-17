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
  late final StoryPreferencesController _prefs;
  late final TextEditingController _heroNameController;
  late final TextEditingController _momNameController;
  late final TextEditingController _dadNameController;
  late final TextEditingController _grandmaNameController;
  late final TextEditingController _grandpaNameController;
  final List<TextEditingController> _brotherNameControllers =
      <TextEditingController>[];
  final List<TextEditingController> _sisterNameControllers =
      <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _prefs = context.read<StoryPreferencesController>();
    _heroNameController = TextEditingController(text: _prefs.heroName);
    _momNameController = TextEditingController(text: _prefs.familyNameMom);
    _dadNameController = TextEditingController(text: _prefs.familyNameDad);
    _grandmaNameController = TextEditingController(
      text: _prefs.familyNameGrandma,
    );
    _grandpaNameController = TextEditingController(
      text: _prefs.familyNameGrandpa,
    );
    _syncSiblingControllers(_brotherNameControllers, _prefs.brothersNames);
    _syncSiblingControllers(_sisterNameControllers, _prefs.sistersNames);
    _prefs.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPreferencesChanged);
    _heroNameController.dispose();
    _momNameController.dispose();
    _dadNameController.dispose();
    _grandmaNameController.dispose();
    _grandpaNameController.dispose();
    _disposeControllers(_brotherNameControllers);
    _disposeControllers(_sisterNameControllers);
    super.dispose();
  }

  void _disposeControllers(List<TextEditingController> values) {
    for (final controller in values) {
      controller.dispose();
    }
    values.clear();
  }

  void _onPreferencesChanged() {
    _syncControllerValue(_heroNameController, _prefs.heroName);
    _syncControllerValue(_momNameController, _prefs.familyNameMom);
    _syncControllerValue(_dadNameController, _prefs.familyNameDad);
    _syncControllerValue(_grandmaNameController, _prefs.familyNameGrandma);
    _syncControllerValue(_grandpaNameController, _prefs.familyNameGrandpa);
    _syncSiblingControllers(_brotherNameControllers, _prefs.brothersNames);
    _syncSiblingControllers(_sisterNameControllers, _prefs.sistersNames);
  }

  void _syncSiblingControllers(
    List<TextEditingController> controllers,
    List<String> values,
  ) {
    while (controllers.length < values.length) {
      controllers.add(TextEditingController());
    }
    while (controllers.length > values.length) {
      controllers.removeLast().dispose();
    }
    for (var index = 0; index < values.length; index++) {
      _syncControllerValue(controllers[index], values[index]);
    }
  }

  void _syncControllerValue(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
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
              onChanged: prefs.setHeroName,
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
                if (prefs.familyMode) ...<Widget>[
                  const SizedBox(height: FairyCraftSpacing.element),
                  Wrap(
                    spacing: FairyCraftSpacing.element,
                    runSpacing: FairyCraftSpacing.element,
                    children: StoryPreferencesController.familyMemberIds
                        .map((memberId) {
                          final selected = prefs.familyMembers.contains(
                            memberId,
                          );
                          return FilterChip(
                            selected: selected,
                            label: Text(_familyLabel(l10n, memberId)),
                            onSelected: (isSelected) {
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
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: FairyCraftSpacing.section),
                  TextField(
                    controller: _momNameController,
                    decoration: InputDecoration(
                      labelText: l10n
                          .storyPreferencesFamilyMemberNameOptionalLabel(
                            l10n.familyMom,
                          ),
                    ),
                    onChanged: prefs.setFamilyNameMom,
                  ),
                  const SizedBox(height: FairyCraftSpacing.element),
                  TextField(
                    controller: _dadNameController,
                    decoration: InputDecoration(
                      labelText: l10n
                          .storyPreferencesFamilyMemberNameOptionalLabel(
                            l10n.familyDad,
                          ),
                    ),
                    onChanged: prefs.setFamilyNameDad,
                  ),
                  const SizedBox(height: FairyCraftSpacing.element),
                  TextField(
                    controller: _grandmaNameController,
                    decoration: InputDecoration(
                      labelText: l10n
                          .storyPreferencesFamilyMemberNameOptionalLabel(
                            l10n.familyGrandma,
                          ),
                    ),
                    onChanged: prefs.setFamilyNameGrandma,
                  ),
                  const SizedBox(height: FairyCraftSpacing.element),
                  TextField(
                    controller: _grandpaNameController,
                    decoration: InputDecoration(
                      labelText: l10n
                          .storyPreferencesFamilyMemberNameOptionalLabel(
                            l10n.familyGrandpa,
                          ),
                    ),
                    onChanged: prefs.setFamilyNameGrandpa,
                  ),
                  const SizedBox(height: FairyCraftSpacing.section),
                  _SiblingNamesSection(
                    title: l10n.storyPreferencesBrothersTitle,
                    emptyHint: l10n.storyPreferencesNoBrothersAddedYet,
                    controllers: _brotherNameControllers,
                    fieldLabelBuilder: (index) => l10n
                        .storyPreferencesBrotherNameOptionalLabel(index + 1),
                    onChanged: (index, value) {
                      prefs.setBrotherNameAt(index, value);
                    },
                    onRemove: (index) {
                      prefs.removeBrotherNameAt(index);
                    },
                    onAdd: prefs.addBrotherName,
                    addButtonLabel: l10n.storyPreferencesAddBrotherButton,
                    removeButtonTooltip: l10n.commonRemove,
                  ),
                  const SizedBox(height: FairyCraftSpacing.section),
                  _SiblingNamesSection(
                    title: l10n.storyPreferencesSistersTitle,
                    emptyHint: l10n.storyPreferencesNoSistersAddedYet,
                    controllers: _sisterNameControllers,
                    fieldLabelBuilder: (index) =>
                        l10n.storyPreferencesSisterNameOptionalLabel(index + 1),
                    onChanged: (index, value) {
                      prefs.setSisterNameAt(index, value);
                    },
                    onRemove: (index) {
                      prefs.removeSisterNameAt(index);
                    },
                    onAdd: prefs.addSisterName,
                    addButtonLabel: l10n.storyPreferencesAddSisterButton,
                    removeButtonTooltip: l10n.commonRemove,
                  ),
                ],
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

class _SiblingNamesSection extends StatelessWidget {
  const _SiblingNamesSection({
    required this.title,
    required this.emptyHint,
    required this.controllers,
    required this.fieldLabelBuilder,
    required this.onChanged,
    required this.onRemove,
    required this.onAdd,
    required this.addButtonLabel,
    required this.removeButtonTooltip,
  });

  final String title;
  final String emptyHint;
  final List<TextEditingController> controllers;
  final String Function(int index) fieldLabelBuilder;
  final void Function(int index, String value) onChanged;
  final ValueChanged<int> onRemove;
  final Future<void> Function([String value]) onAdd;
  final String addButtonLabel;
  final String removeButtonTooltip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: FairyCraftSpacing.element),
        if (controllers.isEmpty)
          Text(
            emptyHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FairyCraftPalette.textSecondary,
            ),
          )
        else
          ...List<Widget>.generate(controllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: FairyCraftSpacing.element),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText: fieldLabelBuilder(index),
                      ),
                      onChanged: (value) => onChanged(index, value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onRemove(index),
                    tooltip: removeButtonTooltip,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                ],
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: () => onAdd(),
          icon: const Icon(Icons.add),
          label: Text(addButtonLabel),
        ),
      ],
    );
  }
}

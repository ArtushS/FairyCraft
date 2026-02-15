import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/nav.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../settings/settings_controller.dart';
import '../shared/ui/fairycraft_theme.dart';
import '../story/story_preferences_controller.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  late final TextEditingController _heroNameController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<StoryPreferencesController>();
    _pageController = PageController();
    _heroNameController = TextEditingController(text: prefs.heroName);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroNameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await context.read<SettingsController>().setOnboardingCompleted(true);
    if (mounted) {
      Nav.resetToHome(context);
    }
  }

  Future<void> _nextStep() async {
    final lastIndex = _steps(context).length - 1;
    if (_currentStep >= lastIndex) {
      await _completeOnboarding();
      return;
    }
    await _pageController.nextPage(
      duration: FairyCraftMotion.standard,
      curve: FairyCraftMotion.curve,
    );
  }

  List<_OnboardingStep> _steps(BuildContext context) {
    final l10n = context.l10n;
    return <_OnboardingStep>[
      _OnboardingStep(
        title: l10n.onboardingHeroTitle,
        description: l10n.onboardingHeroDescription,
        childBuilder: (context) {
          final prefs = context.read<StoryPreferencesController>();
          return TextField(
            controller: _heroNameController,
            decoration: InputDecoration(
              labelText: l10n.onboardingHeroNameLabel,
              hintText: l10n.onboardingHeroNameHint,
            ),
            onChanged: prefs.setHeroName,
          );
        },
      ),
      _OnboardingStep(
        title: l10n.onboardingAgeTitle,
        description: l10n.onboardingAgeDescription,
        childBuilder: (context) {
          final prefs = context.watch<StoryPreferencesController>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.onboardingAgeYears(prefs.targetAge),
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
          );
        },
      ),
      _OnboardingStep(
        title: l10n.onboardingFamilyTitle,
        description: l10n.onboardingFamilyDescription,
        childBuilder: (context) {
          final prefs = context.watch<StoryPreferencesController>();

          return Column(
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.onboardingUseFamilyMode),
                value: prefs.familyMode,
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
          );
        },
      ),
      _OnboardingStep(
        title: l10n.onboardingIllustrationsTitle,
        description: l10n.onboardingIllustrationsDescription,
        childBuilder: (context) {
          final prefs = context.watch<StoryPreferencesController>();
          return Column(
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.onboardingAutoIllustrations),
                value: prefs.autoIllustrations,
                onChanged: prefs.setAutoIllustrations,
              ),
              const SizedBox(height: FairyCraftSpacing.element),
              Text(
                l10n.onboardingCreativityPercent(
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
          );
        },
      ),
    ];
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = _steps(context);
    final isLastStep = _currentStep == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingWelcomeTitle),
        actions: <Widget>[
          TextButton(onPressed: _completeOnboarding, child: Text(l10n.commonSkip)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: FairyCraftSpacing.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _StepDots(total: steps.length, current: _currentStep),
              const SizedBox(height: FairyCraftSpacing.section),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: steps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return AnimatedSwitcher(
                      duration: FairyCraftMotion.standard,
                      switchInCurve: FairyCraftMotion.curve,
                      switchOutCurve: FairyCraftMotion.curve,
                      child: Card(
                        key: ValueKey<String>(step.title),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            FairyCraftSpacing.padding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                step.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: FairyCraftSpacing.element),
                              Text(
                                step.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: FairyCraftSpacing.section),
                              step.childBuilder(context),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: FairyCraftSpacing.section),
              FilledButton(
                onPressed: _nextStep,
                child: Text(isLastStep ? l10n.commonDone : l10n.commonContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.childBuilder,
  });

  final String title;
  final String description;
  final WidgetBuilder childBuilder;
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total, (index) {
        final active = index == current;
        return AnimatedContainer(
          duration: FairyCraftMotion.standard,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: active
                ? FairyCraftPalette.secondary
                : FairyCraftPalette.outline,
          ),
        );
      }),
    );
  }
}

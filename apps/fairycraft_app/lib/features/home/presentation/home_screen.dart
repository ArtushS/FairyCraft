import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/nav.dart';
import '../../../l10n/l10n.dart';
import '../../../settings/settings_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animationsEnabled = context.watch<SettingsController>().reduceMotion;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE7),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 8,
              right: 10,
              child: _TopActions(
                profileTooltip: l10n.homeAccountTooltip,
                sparklesTooltip: l10n.homeStoryPreferences,
                settingsTooltip: l10n.homeSettingsTooltip,
                onProfileTap: () => Nav.toAccount(context),
                onSparklesTap: () => Nav.toStoryPreferences(context),
                onSettingsTap: () => Nav.toSettings(context),
              ),
            ),
            RepaintBoundary(
              child: Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxCircleFromWidth = constraints.maxWidth * 0.66;
                    final maxCircleFromHeight =
                        (constraints.maxHeight - 220) / 2;
                    final circleSize = math
                        .min(maxCircleFromWidth, maxCircleFromHeight)
                        .clamp(190.0, 250.0);
                    final spacing = (constraints.maxHeight * 0.06).clamp(
                      34.0,
                      54.0,
                    );

                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 88, 24, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _HomeCircleButton(
                              icon: Icons.add_rounded,
                              label: l10n.homeCreateStoryTitle,
                              size: circleSize,
                              animate: animationsEnabled,
                              delayMs: 0,
                              onTap: () => Nav.toSetup(context),
                            ),
                            SizedBox(height: spacing),
                            _HomeCircleButton(
                              icon: Icons.menu_book_rounded,
                              label: l10n.homeMyStoriesTitle,
                              size: circleSize,
                              animate: animationsEnabled,
                              delayMs: 80,
                              onTap: () => Nav.toMyStories(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCircleButton extends StatelessWidget {
  const _HomeCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.animate,
    required this.delayMs,
    required this.size,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool animate;
  final int delayMs;
  final double size;

  @override
  Widget build(BuildContext context) {
    const circleBackground = Color(0xFFF8F5F0);
    const iconColor = Color(0xFF716D69);
    const textColor = Color(0xFF1F1D1B);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: animate ? 0.92 : 1.0, end: 1.0),
      duration: animate ? Duration(milliseconds: 420 + delayMs) : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Semantics(
        button: true,
        label: label,
        child: SizedBox.square(
          dimension: size,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              customBorder: const CircleBorder(),
              child: Ink(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleBackground,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 34,
                      spreadRadius: 0,
                      offset: Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Color(0x14FFFFFF),
                      blurRadius: 14,
                      spreadRadius: -2,
                      offset: Offset(-2, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(icon, size: 62, color: iconColor),
                      const SizedBox(height: 16),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions({
    required this.profileTooltip,
    required this.sparklesTooltip,
    required this.settingsTooltip,
    required this.onProfileTap,
    required this.onSparklesTap,
    required this.onSettingsTap,
  });

  final String profileTooltip;
  final String sparklesTooltip;
  final String settingsTooltip;
  final VoidCallback onProfileTap;
  final VoidCallback onSparklesTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TopActionButton(
          icon: Icons.person_outline_rounded,
          tooltip: profileTooltip,
          onTap: onProfileTap,
        ),
        const SizedBox(width: 8),
        _TopActionButton(
          icon: Icons.auto_awesome_rounded,
          tooltip: sparklesTooltip,
          onTap: onSparklesTap,
        ),
        const SizedBox(width: 8),
        _TopActionButton(
          icon: Icons.settings_outlined,
          tooltip: settingsTooltip,
          onTap: onSettingsTap,
        ),
      ],
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 42,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            containedInkWell: true,
            customBorder: const CircleBorder(),
            highlightShape: BoxShape.circle,
            splashColor: const Color(0x15000000),
            highlightColor: const Color(0x10000000),
            child: Icon(icon, size: 29, color: const Color(0xFF4E4A49)),
          ),
        ),
      ),
    );
  }
}

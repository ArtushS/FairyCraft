import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/nav.dart';
import '../../../l10n/l10n.dart';
import '../../../settings/settings_controller.dart';
import '../../../shared/ui/fairycraft_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsController>();
    final motionEnabled = settings.reduceMotion;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: _PremiumHomeBackground(animate: motionEnabled),
            ),
            Positioned(
              top: 8,
              right: 14,
              child: _TopActions(
                profileTooltip: l10n.homeAccountTooltip,
                sparklesTooltip: l10n.homeStoryPreferences,
                settingsTooltip: l10n.homeSettingsTooltip,
                onProfileTap: () => Nav.toAccount(context),
                onSparklesTap: () => Nav.toStoryPreferences(context),
                onSettingsTap: () => Nav.toSettings(context),
              ),
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight - 120;
                  final gap = (availableHeight * 0.12).clamp(56.0, 72.0);
                  final byWidth = (constraints.maxWidth * 0.66).clamp(
                    220.0,
                    250.0,
                  );
                  final byHeight = ((availableHeight - gap) / 2).clamp(
                    190.0,
                    250.0,
                  );
                  final circleSize = math.min(byWidth, byHeight);

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          PremiumActionCircle(
                            icon: Icons.add_rounded,
                            label: l10n.homeCreateStoryTitle,
                            size: circleSize,
                            animate: motionEnabled,
                            phase: 0.18,
                            onTap: () => Nav.toSetup(context),
                          ),
                          SizedBox(height: gap),
                          PremiumActionCircle(
                            icon: Icons.menu_book_rounded,
                            label: l10n.homeMyStoriesTitle,
                            size: circleSize,
                            animate: motionEnabled,
                            phase: 0.62,
                            onTap: () => Nav.toMyStories(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumActionCircle extends StatefulWidget {
  const PremiumActionCircle({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.glowEnabled = true,
    this.animate = true,
    this.size = 236,
    this.phase = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool glowEnabled;
  final bool animate;
  final double size;
  final double phase;

  @override
  State<PremiumActionCircle> createState() => _PremiumActionCircleState();
}

class _PremiumActionCircleState extends State<PremiumActionCircle> {
  static const Duration _pressDuration = Duration(milliseconds: 150);
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final surface = FairyCraftPalette.surface;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          duration: _pressDuration,
          curve: Curves.easeOutCubic,
          scale: _pressed ? 0.985 : 1,
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                if (widget.glowEnabled)
                  Positioned.fill(
                    child: OverflowBox(
                      maxWidth: size * 1.72,
                      maxHeight: size * 1.72,
                      child: SoftAnimatedGlow(
                        animate: widget.animate,
                        pressBoost: _pressed ? 1 : 0,
                        phase: widget.phase,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: _pressDuration,
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        surface.withValues(alpha: 0.96),
                        FairyCraftPalette.background.withValues(alpha: 0.92),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: FairyCraftPalette.primary.withValues(
                          alpha: _pressed ? 0.09 : 0.14,
                        ),
                        blurRadius: _pressed ? 20 : 32,
                        spreadRadius: _pressed ? 0 : 1,
                        offset: Offset(0, _pressed ? 8 : 14),
                      ),
                      BoxShadow(
                        color: FairyCraftPalette.secondary.withValues(
                          alpha: _pressed ? 0.10 : 0.15,
                        ),
                        blurRadius: _pressed ? 10 : 15,
                        spreadRadius: 0,
                        offset: Offset(0, _pressed ? 3 : 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.35, -0.45),
                          radius: 1.05,
                          colors: <Color>[
                            Colors.white.withValues(alpha: 0.40),
                            Colors.white.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const <double>[0.0, 0.52, 1.0],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.48),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.20),
                                ),
                              ),
                              child: Icon(
                                widget.icon,
                                size: 34,
                                color: FairyCraftPalette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                    color: FairyCraftPalette.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoftAnimatedGlow extends StatefulWidget {
  const SoftAnimatedGlow({
    super.key,
    required this.animate,
    required this.pressBoost,
    required this.phase,
  });

  final bool animate;
  final double pressBoost;
  final double phase;

  @override
  State<SoftAnimatedGlow> createState() => _SoftAnimatedGlowState();
}

class _SoftAnimatedGlowState extends State<SoftAnimatedGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  @override
  void initState() {
    super.initState();
    final phase = widget.phase.clamp(0.0, 1.0);
    _controller.value = phase;
    _toggleAnimation(widget.animate);
  }

  @override
  void didUpdateWidget(covariant SoftAnimatedGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      _toggleAnimation(widget.animate);
    }
  }

  void _toggleAnimation(bool animate) {
    if (animate) {
      _controller.repeat(reverse: true);
      return;
    }
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = widget.animate
                ? Curves.easeInOut.transform(_controller.value)
                : 0.45;
            final opacity = (0.05 + (t * 0.07) + (widget.pressBoost * 0.03))
                .clamp(0.05, 0.16);
            final scale = (0.98 + (t * 0.07) + (widget.pressBoost * 0.02))
                .clamp(0.98, 1.10);

            return Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.78,
                    colors: <Color>[
                      FairyCraftPalette.primary.withValues(alpha: opacity),
                      FairyCraftPalette.secondary.withValues(
                        alpha: opacity * 0.82,
                      ),
                      Colors.white.withValues(alpha: opacity * 0.44),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.44, 0.68, 1.0],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumHomeBackground extends StatelessWidget {
  const _PremiumHomeBackground({required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  FairyCraftPalette.background,
                  const Color(0xFFF8F0EB),
                  FairyCraftPalette.surface.withValues(alpha: 0.9),
                ],
                stops: const <double>[0.0, 0.52, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(child: _AmbientDriftGlow(animate: animate)),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.26),
                    Colors.white.withValues(alpha: 0.02),
                    Colors.black.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmbientDriftGlow extends StatefulWidget {
  const _AmbientDriftGlow({required this.animate});

  final bool animate;

  @override
  State<_AmbientDriftGlow> createState() => _AmbientDriftGlowState();
}

class _AmbientDriftGlowState extends State<_AmbientDriftGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3800),
  );

  @override
  void initState() {
    super.initState();
    _toggleAnimation(widget.animate);
  }

  @override
  void didUpdateWidget(covariant _AmbientDriftGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      _toggleAnimation(widget.animate);
    }
  }

  void _toggleAnimation(bool animate) {
    if (animate) {
      _controller.repeat(reverse: true);
      return;
    }
    _controller.stop();
    _controller.value = 0.5;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = widget.animate
                ? Curves.easeInOut.transform(_controller.value)
                : 0.5;
            final coolCenter = Alignment.lerp(
              const Alignment(-0.7, -0.3),
              const Alignment(0.66, 0.20),
              t,
            );
            final warmCenter = Alignment.lerp(
              const Alignment(0.85, -0.75),
              const Alignment(-0.72, 0.9),
              t,
            );

            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: coolCenter ?? Alignment.center,
                        radius: 1.18,
                        colors: <Color>[
                          FairyCraftPalette.primary.withValues(
                            alpha: widget.animate ? 0.09 : 0.05,
                          ),
                          Colors.transparent,
                        ],
                        stops: const <double>[0.0, 0.90],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: warmCenter ?? Alignment.center,
                        radius: 1.08,
                        colors: <Color>[
                          FairyCraftPalette.secondary.withValues(
                            alpha: widget.animate ? 0.085 : 0.05,
                          ),
                          Colors.transparent,
                        ],
                        stops: const <double>[0.0, 0.88],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
        dimension: 44,
        child: Material(
          color: FairyCraftPalette.surface.withValues(alpha: 0.56),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkResponse(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            containedInkWell: true,
            customBorder: const CircleBorder(),
            highlightShape: BoxShape.circle,
            splashColor: FairyCraftPalette.primary.withValues(alpha: 0.10),
            highlightColor: FairyCraftPalette.primary.withValues(alpha: 0.07),
            child: Icon(
              icon,
              size: 20,
              color: FairyCraftPalette.textPrimary.withValues(alpha: 0.94),
            ),
          ),
        ),
      ),
    );
  }
}

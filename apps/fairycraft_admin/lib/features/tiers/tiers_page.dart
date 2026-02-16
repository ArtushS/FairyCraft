import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/subscription_tier_model.dart';
import '../../data/repositories/tiers_repository.dart';

class TiersPage extends StatefulWidget {
  const TiersPage({super.key});

  @override
  State<TiersPage> createState() => _TiersPageState();
}

class _TiersPageState extends State<TiersPage> {
  bool _loading = true;
  String? _error;
  List<SubscriptionTierModel> _tiers = <SubscriptionTierModel>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tiers = await context.read<TiersRepository>().fetchAll();
      if (mounted) {
        setState(() {
          _tiers = tiers;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveTier(SubscriptionTierModel tier) async {
    await context.read<TiersRepository>().save(tier);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved tier: ${tier.id}')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Subscription Tiers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 12),
        ..._tiers.map(
          (tier) => _TierCard(
            key: ValueKey<String>(tier.id),
            tier: tier,
            onSave: _saveTier,
          ),
        ),
      ],
    );
  }
}

class _TierCard extends StatefulWidget {
  const _TierCard({super.key, required this.tier, required this.onSave});

  final SubscriptionTierModel tier;
  final Future<void> Function(SubscriptionTierModel tier) onSave;

  @override
  State<_TierCard> createState() => _TierCardState();
}

class _TierCardState extends State<_TierCard> {
  late final TextEditingController _storiesPerDayController;
  late final TextEditingController _imagesPerStoryController;
  late final TextEditingController _maxContinuationDepthController;
  late String _maxStoryLength;
  late bool _active;
  late bool _allowVoiceInput;
  late bool _allowTts;
  late bool _allowPrintOrder;
  late bool _allowToyOrder;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromTier(widget.tier);
  }

  @override
  void didUpdateWidget(covariant _TierCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tier != widget.tier) {
      _storiesPerDayController.dispose();
      _imagesPerStoryController.dispose();
      _maxContinuationDepthController.dispose();
      _hydrateFromTier(widget.tier);
    }
  }

  void _hydrateFromTier(SubscriptionTierModel tier) {
    _storiesPerDayController = TextEditingController(
      text: tier.limits.storiesPerDay.toString(),
    );
    _imagesPerStoryController = TextEditingController(
      text: tier.limits.imagesPerStory.toString(),
    );
    _maxContinuationDepthController = TextEditingController(
      text: tier.limits.maxContinuationDepth.toString(),
    );
    _maxStoryLength = tier.limits.maxStoryLength;
    _active = tier.active;
    _allowVoiceInput = tier.limits.allowVoiceInput;
    _allowTts = tier.limits.allowTts;
    _allowPrintOrder = tier.limits.allowPrintOrder;
    _allowToyOrder = tier.limits.allowToyOrder;
  }

  @override
  void dispose() {
    _storiesPerDayController.dispose();
    _imagesPerStoryController.dispose();
    _maxContinuationDepthController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });
    final tier = widget.tier.copyWith(
      active: _active,
      limits: widget.tier.limits.copyWith(
        storiesPerDay: int.tryParse(_storiesPerDayController.text.trim()) ?? 1,
        imagesPerStory:
            int.tryParse(_imagesPerStoryController.text.trim()) ?? 0,
        maxStoryLength: _maxStoryLength,
        maxContinuationDepth:
            int.tryParse(_maxContinuationDepthController.text.trim()) ?? 1,
        allowVoiceInput: _allowVoiceInput,
        allowTts: _allowTts,
        allowPrintOrder: _allowPrintOrder,
        allowToyOrder: _allowToyOrder,
      ),
    );
    await widget.onSave(tier);
    if (mounted) {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  widget.tier.id.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Switch(
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
                const Text('Active'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _storiesPerDayController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Stories per day'),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _imagesPerStoryController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Images per story'),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    initialValue: _maxStoryLength,
                    decoration:
                        const InputDecoration(labelText: 'Max story length'),
                    items: const <String>['short', 'medium', 'long']
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _maxStoryLength = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _maxContinuationDepthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max continuation depth',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                FilterChip(
                  selected: _allowVoiceInput,
                  label: const Text('Allow voice input'),
                  onSelected: (value) =>
                      setState(() => _allowVoiceInput = value),
                ),
                FilterChip(
                  selected: _allowTts,
                  label: const Text('Allow TTS'),
                  onSelected: (value) => setState(() => _allowTts = value),
                ),
                FilterChip(
                  selected: _allowPrintOrder,
                  label: const Text('Allow print order'),
                  onSelected: (value) =>
                      setState(() => _allowPrintOrder = value),
                ),
                FilterChip(
                  selected: _allowToyOrder,
                  label: const Text('Allow toy order'),
                  onSelected: (value) =>
                      setState(() => _allowToyOrder = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save tier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

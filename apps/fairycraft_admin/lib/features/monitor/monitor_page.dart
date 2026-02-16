import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/generation_log_model.dart';
import '../../data/repositories/logs_repository.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  static const int _pageSize = 25;
  bool _loading = true;
  String? _error;
  List<GenerationLogModel> _logs = <GenerationLogModel>[];
  int _page = 0;

  String _status = '';
  String _provider = '';
  String _tier = '';
  String _language = '';

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
      final logs = await context.read<LogsRepository>().fetchRecent(
            status: _status,
            provider: _provider,
            tier: _tier,
            language: _language,
            limit: 200,
          );
      if (mounted) {
        setState(() {
          _logs = logs;
          _page = 0;
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

  int get _maxPage {
    if (_logs.isEmpty) {
      return 0;
    }
    return (_logs.length - 1) ~/ _pageSize;
  }

  List<GenerationLogModel> get _currentPageItems {
    final start = _page * _pageSize;
    final end = (_page + 1) * _pageSize;
    if (start >= _logs.length) {
      return <GenerationLogModel>[];
    }
    return _logs.sublist(start, end > _logs.length ? _logs.length : end);
  }

  Future<void> _showDetails(GenerationLogModel log) async {
    final detail = <String, dynamic>{
      'id': log.id,
      'createdAt': log.createdAt.toIso8601String(),
      'userIdHash': log.userIdHash,
      'tier': log.tier,
      'language': log.language,
      'age': log.age,
      'requestSummary': log.requestSummary,
      'effectivePolicyId': log.effectivePolicyId,
      'templateIdsUsed': log.templateIdsUsed,
      'status': log.status,
      'provider': log.provider,
      'latencyMs': log.latencyMs,
      'errorCode': log.errorCode,
      'errorMessage': log.errorMessage,
    };

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log ${log.id}'),
        content: SizedBox(
          width: 780,
          child: SingleChildScrollView(
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(detail),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            _buildFilterDropdown(
              label: 'Status',
              value: _status,
              options: const <String>['', 'ok', 'blocked', 'error'],
              onChanged: (value) => setState(() => _status = value),
            ),
            _buildFilterDropdown(
              label: 'Provider',
              value: _provider,
              options: const <String>['', 'mock', 'gpt', 'vertex'],
              onChanged: (value) => setState(() => _provider = value),
            ),
            _buildFilterDropdown(
              label: 'Tier',
              value: _tier,
              options: const <String>['', 'free', 'pro', 'premium'],
              onChanged: (value) => setState(() => _tier = value),
            ),
            _buildFilterDropdown(
              label: 'Language',
              value: _language,
              options: const <String>['', 'en', 'ru', 'hy'],
              onChanged: (value) => setState(() => _language = value),
            ),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Apply'),
            ),
          ],
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('Generation Logs (${_logs.length})'),
                subtitle: const Text('Last 200 records'),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 520,
                child: ListView.builder(
                  itemCount: _currentPageItems.length,
                  itemBuilder: (context, index) {
                    final log = _currentPageItems[index];
                    return ListTile(
                      leading: _statusBadge(log.status),
                      title: Text(
                        '${log.provider} | tier=${log.tier} | lang=${log.language} | age=${log.age}',
                      ),
                      subtitle: Text(
                        'policy=${log.effectivePolicyId} latency=${log.latencyMs}ms',
                      ),
                      trailing: TextButton(
                        onPressed: () => _showDetails(log),
                        child: const Text('Details'),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Text('Page ${_page + 1} / ${_maxPage + 1}'),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: _page > 0
                          ? () {
                              setState(() {
                                _page -= 1;
                              });
                            }
                          : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _page < _maxPage
                          ? () {
                              setState(() {
                                _page += 1;
                              });
                            }
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text('$label: ${option.isEmpty ? 'all' : option}'),
            ),
          )
          .toList(growable: false),
      onChanged: (next) {
        if (next == null) {
          return;
        }
        onChanged(next);
      },
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) {
      'ok' => Colors.green,
      'blocked' => Colors.orange,
      'error' => Colors.red,
      _ => Colors.blueGrey,
    };

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

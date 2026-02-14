import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

const _useMockAdmin = bool.fromEnvironment('USE_MOCK_ADMIN', defaultValue: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var mockMode = _useMockAdmin;
  if (!mockMode) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (_) {
      mockMode = true;
    }
  }

  final state = AdminState(mockMode: mockMode);
  await state.init();

  runApp(
    ChangeNotifierProvider<AdminState>.value(
      value: state,
      child: const FairyCraftAdminApp(),
    ),
  );
}

class FairyCraftAdminApp extends StatelessWidget {
  const FairyCraftAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FairyCraft Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B7285)),
        useMaterial3: true,
      ),
      home: const AdminRootPage(),
    );
  }
}

class AdminState extends ChangeNotifier {
  AdminState({required this.mockMode});

  final bool mockMode;

  User? _firebaseUser;
  bool _mockLoggedIn = false;
  bool _adminClaim = false;

  Map<String, dynamic> _policy = <String, dynamic>{
    'enable_story_generation': true,
    'enable_illustrations': true,
    'model_allowlist': <String>['gemini-2.0-flash'],
    'max_output_tokens': 600,
    'temperature': 0.6,
    'max_input_chars': 4000,
    'max_output_chars': 5000,
    'daily_story_limit': 20,
    'ip_rate_per_min': 60,
    'uid_rate_per_min': 40,
    'max_body_kb': 64,
    'request_timeout_ms': 20000,
  };

  List<Map<String, dynamic>> _usageItems = <Map<String, dynamic>>[];

  bool get isLoggedIn => mockMode ? _mockLoggedIn : _firebaseUser != null;
  bool get hasAdminClaim => mockMode ? true : _adminClaim;
  Map<String, dynamic> get policy => _policy;
  List<Map<String, dynamic>> get usageItems => _usageItems;

  Future<void> init() async {
    if (mockMode) {
      notifyListeners();
      return;
    }

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _firebaseUser = user;
      _adminClaim = await _checkAdminClaim();
      notifyListeners();
    });

    _firebaseUser = FirebaseAuth.instance.currentUser;
    _adminClaim = await _checkAdminClaim();
    notifyListeners();
  }

  Future<bool> _checkAdminClaim() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    final idTokenResult = await user.getIdTokenResult(true);
    return idTokenResult.claims?['admin'] == true;
  }

  Future<void> signIn(String email, String password) async {
    if (mockMode) {
      _mockLoggedIn = true;
      notifyListeners();
      return;
    }
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    if (mockMode) {
      _mockLoggedIn = false;
      notifyListeners();
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<void> loadPolicy() async {
    if (mockMode) {
      notifyListeners();
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('admin_policy').doc('runtime').get();
    _policy = doc.data() ?? <String, dynamic>{};
    notifyListeners();
  }

  Future<void> savePolicy(Map<String, dynamic> nextPolicy) async {
    _policy = nextPolicy;
    if (!mockMode) {
      await FirebaseFirestore.instance.collection('admin_policy').doc('runtime').set(nextPolicy);
    }
    notifyListeners();
  }

  Future<void> loadUsage() async {
    if (mockMode) {
      _usageItems = <Map<String, dynamic>>[
        <String, dynamic>{'id': 'mock_user_20260214', 'count': 4, 'uid': 'mock_user', 'date': '20260214'},
      ];
      notifyListeners();
      return;
    }

    final snapshot = await FirebaseFirestore.instance.collection('usage_daily').limit(100).get();
    _usageItems = snapshot.docs
        .map((doc) => <String, dynamic>{'id': doc.id, ...(doc.data())})
        .toList(growable: false);
    notifyListeners();
  }
}

class AdminRootPage extends StatelessWidget {
  const AdminRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    if (!state.isLoggedIn) {
      return const AdminLoginPage();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.mockMode ? 'FairyCraft Admin (Mock)' : 'FairyCraft Admin'),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.read<AdminState>().signOut(),
              child: const Text('Sign out'),
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Policy'),
              Tab(text: 'Stats'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            PolicyTab(),
            StatsTab(),
          ],
        ),
      ),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await context.read<AdminState>().signIn(_emailController.text.trim(), _passwordController.text);
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FairyCraft Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting ? const CircularProgressIndicator() : const Text('Sign in'),
            ),
            const SizedBox(height: 8),
            Text(
              _useMockAdmin
                  ? 'Running in mock mode. Any credentials will sign in.'
                  : 'Use Firebase email/password credentials.',
            ),
          ],
        ),
      ),
    );
  }
}

class PolicyTab extends StatefulWidget {
  const PolicyTab({super.key});

  @override
  State<PolicyTab> createState() => _PolicyTabState();
}

class _PolicyTabState extends State<PolicyTab> {
  final _controller = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<AdminState>();
    await state.loadPolicy();
    _controller.text = const JsonEncoder.withIndent('  ').convert(state.policy);
    if (mounted) {
      setState(() {
        _message = state.hasAdminClaim || state.mockMode
            ? null
            : 'Current account has no admin claim. Firestore rules will deny writes.';
      });
    }
  }

  Future<void> _save() async {
    try {
      final parsed = jsonDecode(_controller.text);
      if (parsed is! Map<String, dynamic>) {
        setState(() {
          _message = 'Policy must be a JSON object.';
        });
        return;
      }
      await context.read<AdminState>().savePolicy(parsed);
      setState(() {
        _message = 'Policy saved.';
      });
    } catch (error) {
      setState(() {
        _message = 'Invalid JSON or save error: $error';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Mode: ${state.mockMode ? 'mock' : 'firebase'}'),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              expands: true,
              maxLines: null,
              minLines: null,
              decoration: const InputDecoration(
                labelText: 'admin_policy/runtime JSON',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              FilledButton(onPressed: _save, child: const Text('Save policy')),
              OutlinedButton(onPressed: _load, child: const Text('Reload')),
            ],
          ),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_message!),
          ],
        ],
      ),
    );
  }
}

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  @override
  void initState() {
    super.initState();
    context.read<AdminState>().loadUsage();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();

    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('usage_daily'),
          subtitle: Text(state.mockMode ? 'Mock data' : 'Firestore data'),
          trailing: IconButton(
            onPressed: () => context.read<AdminState>().loadUsage(),
            icon: const Icon(Icons.refresh),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.usageItems.length,
            itemBuilder: (context, index) {
              final item = state.usageItems[index];
              return ListTile(
                title: Text(item['id']?.toString() ?? '-'),
                subtitle: Text('uid=${item['uid'] ?? '-'} count=${item['count'] ?? '-'} date=${item['date'] ?? '-'}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

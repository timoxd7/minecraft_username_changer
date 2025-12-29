import 'package:flutter/material.dart';

import 'models/minecraft_account.dart';
import 'services/minecraft_account_service.dart';

void main() {
  runApp(const MinecraftUsernameApp());
}

class MinecraftUsernameApp extends StatelessWidget {
  const MinecraftUsernameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minecraft Username Changer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = MinecraftAccountService();
  final _usernameController = TextEditingController();

  MinecraftAccount? _account;
  bool _isLoading = true;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final account = await _service.readAccount();
      setState(() {
        _account = account;
        _usernameController.text = account?.username ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load account: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUsername() async {
    final account = _account;
    if (account == null) return;

    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      setState(() => _error = 'Username cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      await _service.updateUsername(account, newUsername);
      setState(() {
        _account = account.copyWith(
          username: newUsername,
          profileName: newUsername,
        );
        _successMessage = 'Username saved successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to save: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minecraft Username Changer'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_account == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'No Minecraft account found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Expected file at:\n${_service.launcherAccountsPath}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAccount,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Minecraft icon placeholder
        const Icon(Icons.games, size: 64, color: Colors.green),
        const SizedBox(height: 24),

        // Current username info
        Text(
          'Current Profile Name: ${_account!.profileName}',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Current Username: ${_account!.username}',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Username input
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'New Username',
            hintText: 'Enter your new username',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          onSubmitted: (_) => _saveUsername(),
        ),
        const SizedBox(height: 16),

        // Error message
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),

        // Success message
        if (_successMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Text(
              _successMessage!,
              style: const TextStyle(color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 16),

        // Save button
        FilledButton.icon(
          onPressed: _saveUsername,
          icon: const Icon(Icons.save),
          label: const Text('Save Username'),
        ),
      ],
    );
  }
}

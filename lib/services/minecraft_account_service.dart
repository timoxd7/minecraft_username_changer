import 'dart:convert';
import 'dart:io';

import '../models/minecraft_account.dart';

/// Service to read and write Minecraft launcher accounts.
class MinecraftAccountService {
  /// Gets the path to the launcher_accounts.json file based on the current OS.
  String get launcherAccountsPath {
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/Library/Application Support/minecraft/launcher_accounts.json';
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '';
      return '$appData\\.minecraft\\launcher_accounts.json';
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/.minecraft/launcher_accounts.json';
    }
    throw UnsupportedError('Unsupported operating system');
  }

  /// Reads the current Minecraft account from the launcher file.
  Future<MinecraftAccount?> readAccount() async {
    final file = File(launcherAccountsPath);

    if (!await file.exists()) {
      return null;
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    final accounts = json['accounts'] as Map<String, dynamic>?;
    if (accounts == null || accounts.isEmpty) {
      return null;
    }

    // Get the first (and usually only) account
    final accountId = accounts.keys.first;
    final accountData = accounts[accountId] as Map<String, dynamic>;

    final minecraftProfile =
        accountData['minecraftProfile'] as Map<String, dynamic>?;
    final profileName = minecraftProfile?['name'] as String? ?? '';
    final username = accountData['username'] as String? ?? '';

    return MinecraftAccount(
      localId: accountId,
      profileName: profileName,
      username: username,
    );
  }

  /// Updates the username in the launcher file.
  Future<void> updateUsername(
    MinecraftAccount account,
    String newUsername,
  ) async {
    final file = File(launcherAccountsPath);

    if (!await file.exists()) {
      throw Exception('Launcher accounts file not found');
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    final accounts = json['accounts'] as Map<String, dynamic>?;
    if (accounts == null) {
      throw Exception('No accounts found in file');
    }

    final accountData = accounts[account.localId] as Map<String, dynamic>?;
    if (accountData == null) {
      throw Exception('Account not found');
    }

    // Update both username fields
    accountData['username'] = newUsername;

    final minecraftProfile =
        accountData['minecraftProfile'] as Map<String, dynamic>?;
    if (minecraftProfile != null) {
      minecraftProfile['name'] = newUsername;
    }

    // Write back with proper formatting
    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(json));
  }
}

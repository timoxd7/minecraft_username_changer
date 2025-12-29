/// Represents a Minecraft account from the launcher_accounts.json file.
class MinecraftAccount {
  final String localId;
  final String profileName;
  final String username;

  const MinecraftAccount({
    required this.localId,
    required this.profileName,
    required this.username,
  });

  /// Creates a copy with updated values.
  MinecraftAccount copyWith({String? profileName, String? username}) {
    return MinecraftAccount(
      localId: localId,
      profileName: profileName ?? this.profileName,
      username: username ?? this.username,
    );
  }
}

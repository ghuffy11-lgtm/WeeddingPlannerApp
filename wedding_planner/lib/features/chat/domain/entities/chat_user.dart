/// Represents a user in the chat system
class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final ChatUserType type;
  final bool isOnline;
  final DateTime? lastSeen;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.type,
    this.isOnline = false,
    this.lastSeen,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get lastSeenText {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final diff = now.difference(lastSeen!);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return 'Long time ago';
  }
}

enum ChatUserType {
  couple,
  vendor;

  String get displayName {
    switch (this) {
      case ChatUserType.couple:
        return 'Couple';
      case ChatUserType.vendor:
        return 'Vendor';
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  final int totalBattles;
  final int wins;
  final int losses;
  final int favoriteCharacterId;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.lastLoginAt,
    this.totalBattles = 0,
    this.wins = 0,
    this.losses = 0,
    this.favoriteCharacterId = 0,
  });

  double getWinRate() {
    if (totalBattles == 0) return 0;
    return (wins / totalBattles) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName ?? email.split('@')[0],
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'totalBattles': totalBattles,
      'wins': wins,
      'losses': losses,
      'favoriteCharacterId': favoriteCharacterId,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
      lastLoginAt: map['lastLoginAt'] is Timestamp
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
      totalBattles: map['totalBattles'] ?? 0,
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      favoriteCharacterId: map['favoriteCharacterId'] ?? 0,
    );
  }

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? totalBattles,
    int? wins,
    int? losses,
    int? favoriteCharacterId,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalBattles: totalBattles ?? this.totalBattles,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      favoriteCharacterId: favoriteCharacterId ?? this.favoriteCharacterId,
    );
  }

  User recordBattle({required bool won}) {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: createdAt,
      lastLoginAt: DateTime.now(),
      totalBattles: totalBattles + 1,
      wins: wins + (won ? 1 : 0),
      losses: losses + (won ? 0 : 1),
      favoriteCharacterId: favoriteCharacterId,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, wins: $wins, losses: $losses, winRate: ${getWinRate().toStringAsFixed(1)}%)';
  }
}

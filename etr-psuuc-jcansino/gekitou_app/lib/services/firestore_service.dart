import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _charactersCollection =>
      _firestore.collection('characters');

  Future<void> createUserDocument(String uid, User user) async {
    try {
      await _usersCollection.doc(uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  Future<User?> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return User.fromMap(doc.data() ?? {});
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required String displayName,
  }) async {
    try {
      await _usersCollection.doc(uid).set({
        'displayName': displayName,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> updateLastLogin(String uid) async {
    try {
      await _usersCollection.doc(uid).set({
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  Future<void> saveBattleResult({
    required String uid,
    required Map<String, dynamic> battleResult,
  }) async {
    try {
      await _usersCollection
          .doc(uid)
          .collection('battles')
          .doc(battleResult['battleId'])
          .set(battleResult);

      final bool playerWon = battleResult['playerWon'] ?? false;

      await _usersCollection.doc(uid).update({
        'totalBattles': FieldValue.increment(1),
        'wins': FieldValue.increment(playerWon ? 1 : 0),
        'losses': FieldValue.increment(playerWon ? 0 : 1),
      });
    } catch (e) {
      throw Exception('Failed to save battle result: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBattleHistory(
    String uid, {
    int limit = 50,
  }) async {
    try {
      final query = _usersCollection
          .doc(uid)
          .collection('battles')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch battle history: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getBattleHistoryStream(String uid) {
    try {
      return _usersCollection
          .doc(uid)
          .collection('battles')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      throw Exception('Failed to stream battle history: $e');
    }
  }

  Future<Map<String, dynamic>> getBattleStats(String uid) async {
    try {
      final user = await getUserData(uid);
      if (user == null) return {};
      return {
        'totalBattles': user.totalBattles,
        'wins': user.wins,
        'losses': user.losses,
        'winRate': user.getWinRate(),
      };
    } catch (e) {
      throw Exception('Failed to fetch battle stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    try {
      final query = _usersCollection
          .where('totalBattles', isGreaterThan: 0)
          .orderBy('totalBattles', descending: true)
          .orderBy('wins', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'uid': doc.id};
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  Future<void> saveCharacterCache(
    String characterId,
    Map<String, dynamic> characterData,
  ) async {
    try {
      await _charactersCollection
          .doc(characterId)
          .set(characterData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to cache character: $e');
    }
  }

  Future<Map<String, dynamic>?> getCachedCharacter(String characterId) async {
    try {
      final doc = await _charactersCollection.doc(characterId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Failed to fetch cached character: $e');
    }
  }

  Future<void> deleteUserData(String uid) async {
    try {
      final batch = _firestore.batch();

      final battles = await _usersCollection
          .doc(uid)
          .collection('battles')
          .get();

      for (var doc in battles.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_usersCollection.doc(uid));
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final snapshot = await _usersCollection
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        return {...doc.data(), 'uid': doc.id};
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<String?> getMostUsedCharacter(String uid) async {
    try {
      final battles = await _usersCollection
          .doc(uid)
          .collection('battles')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      if (battles.docs.isEmpty) return null;

      final characterCounts = <String, int>{};
      for (var doc in battles.docs) {
        final characterId = doc['playerCharacterId'] as String?;
        if (characterId != null) {
          characterCounts[characterId] =
              (characterCounts[characterId] ?? 0) + 1;
        }
      }

      String? mostUsed;
      int maxCount = 0;
      characterCounts.forEach((id, count) {
        if (count > maxCount) {
          maxCount = count;
          mostUsed = id;
        }
      });

      return mostUsed;
    } catch (e) {
      throw Exception('Failed to get most used character: $e');
    }
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kid_profile.dart';

class LocalProfileService {
  static const _key = 'kid_profiles';

  static Future<List<KidProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null || data.isEmpty) return [];

    final List decoded = jsonDecode(data);
    return decoded
        .map((e) => KidProfile.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveProfiles(List<KidProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profiles.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> addProfile(KidProfile profile) async {
    final profiles = await getProfiles();
    profiles.add(profile);
    await saveProfiles(profiles);
  }

  static Future<void> updateProfile(KidProfile updatedProfile) async {
    final profiles = await getProfiles();
    final index = profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index == -1) {
      throw Exception('Profile not found');
    }
    profiles[index] = updatedProfile;
    await saveProfiles(profiles);
  }

  static Future<void> deleteProfile(String id) async {
    final profiles = await getProfiles();
    profiles.removeWhere((p) => p.id == id);
    await saveProfiles(profiles);
  }
}

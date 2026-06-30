import 'package:shared_preferences/shared_preferences.dart';

class ProfileStatsHelper {
  static Future<void> addStars(String profileId, int starsToAdd) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'total_stars_$profileId'; // ✅ Use ID
    final currentStars = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentStars + starsToAdd);
  }

  static Future<void> incrementGame(
    String profileId,
    String category,
    String difficulty,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final gamesKey = 'games_played_$profileId';
    final gamesPlayed = prefs.getInt(gamesKey) ?? 0;
    await prefs.setInt(gamesKey, gamesPlayed + 1);

    final categoryKey = 'category_counts_$profileId';
    final categoryMap = Map<String, int>.from(
      prefs.getStringList(categoryKey)?.asMap().map((k, v) {
            final parts = v.split(':');
            return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
          }) ??
          {},
    );
    categoryMap[category] = (categoryMap[category] ?? 0) + 1;

    final categoryList = categoryMap.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
    await prefs.setStringList(categoryKey, categoryList);

    final diffKey = 'difficulty_counts_$profileId';
    final diffMap = Map<String, int>.from(
      prefs.getStringList(diffKey)?.asMap().map((k, v) {
            final parts = v.split(':');
            return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
          }) ??
          {},
    );
    diffMap[difficulty] = (diffMap[difficulty] ?? 0) + 1;

    final diffList = diffMap.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList(diffKey, diffList);
  }

  static Future<String> getMostPlayedCategory(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final categoryKey = 'category_counts_$profileId';
    final categoryList = prefs.getStringList(categoryKey) ?? [];
    if (categoryList.isEmpty) return 'None';

    final categoryMap = Map<String, int>.fromEntries(
      categoryList.map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
      }),
    );

    final sorted = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  static Future<String> getFavoriteDifficulty(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final diffKey = 'difficulty_counts_$profileId';
    final diffList = prefs.getStringList(diffKey) ?? [];
    if (diffList.isEmpty) return 'None';

    final diffMap = Map<String, int>.fromEntries(
      diffList.map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
      }),
    );

    final sorted = diffMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}

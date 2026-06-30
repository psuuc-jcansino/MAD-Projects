import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinky_app/screens/home_screen.dart';

import '../constants/category.dart';
import '../constants/category_theme.dart';
import '../models/kid_profile.dart';
import '../widgets/animated_star.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final CategoryType category;
  final String difficulty;
  final KidProfile profile;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.category,
    required this.difficulty,
    required this.profile,
  });

  int get stars {
    final percent = score / total;
    if (percent >= 0.8) return 3;
    if (percent >= 0.5) return 2;
    return 1;
  }

  String get title {
    if (stars == 3) return 'Awesome!';
    if (stars == 2) return 'Nice Work!';
    return 'Good Try!';
  }

  String get message {
    if (stars == 3) return 'Amazing work!\nYou did great!';
    if (stars == 2) return 'Nice try!\nYou are learning more every time.';
    return 'Good effort!\nKeep practicing and have fun.';
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = profile.id;

    final starsKey = 'total_stars_$profileId';
    final currentStars = prefs.getInt(starsKey) ?? 0;
    await prefs.setInt(starsKey, currentStars + stars);

    final categoryKey = 'category_counts_$profileId';
    final categoryList = prefs.getStringList(categoryKey) ?? [];
    final Map<String, int> categoryMap = Map.fromEntries(
      categoryList.map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
      }),
    );
    categoryMap[category.name] = (categoryMap[category.name] ?? 0) + 1;
    await prefs.setStringList(
      categoryKey,
      categoryMap.entries.map((e) => '${e.key}:${e.value}').toList(),
    );

    final diffKey = 'difficulty_counts_$profileId';
    final diffList = prefs.getStringList(diffKey) ?? [];
    final Map<String, int> diffMap = Map.fromEntries(
      diffList.map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
      }),
    );
    diffMap[difficulty] = (diffMap[difficulty] ?? 0) + 1;
    await prefs.setStringList(
      diffKey,
      diffMap.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = categoryThemes[category]!;

    Future.microtask(_saveProgress);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 22,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: theme.accentColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedStar(
                          filled: index < stars,
                          delayMs: index * 260,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    Text(
                      '$score / $total',
                      style: GoogleFonts.fredoka(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),

                    _ActionButton(
                      label: 'Play Again',
                      color: theme.accentColor,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 14),

                    _ActionButton(
                      label: 'Back to Home',
                      color: Colors.grey.shade200,
                      textColor: Colors.black87,
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(profile: profile),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

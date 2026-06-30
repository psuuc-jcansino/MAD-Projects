import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/category.dart';
import '../models/difficulty.dart';
import '../models/kid_profile.dart';
import 'game_screen.dart';

class DifficultyScreen extends StatelessWidget {
  final CategoryType category;
  final KidProfile profile;
  final int totalStars;

  const DifficultyScreen({
    super.key,
    required this.category,
    required this.profile,
    required this.totalStars,
  });

  @override
  Widget build(BuildContext context) {
    final level = (totalStars ~/ 10) + 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6EC6FF), Color(0xFFFFF4D8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _SoftDecor(),
              Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose Difficulty',
                    style: GoogleFonts.fredoka(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 3),
                          blurRadius: 6,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _titleForCategory(category),
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: Difficulty.values.map((difficulty) {
                          final unlocked = _isDifficultyUnlocked(
                            difficulty,
                            level,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 22),
                            child: _DifficultyCard(
                              difficulty: difficulty,
                              locked: !unlocked,
                              lockMessage: difficulty == Difficulty.medium
                                  ? 'Reach Level 5 to unlock'
                                  : 'Reach Level 10 to unlock',
                              onTap: unlocked
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GameScreen(
                                            category: category,
                                            difficulty: difficulty,
                                            profile: profile,
                                          ),
                                        ),
                                      );
                                    }
                                  : () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            difficulty == Difficulty.medium
                                                ? 'Finish more games to reach Level 5 ⭐'
                                                : 'Keep going! Level 10 unlocks this 🔥',
                                          ),
                                        ),
                                      );
                                    },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDifficultyUnlocked(Difficulty difficulty, int level) {
    switch (difficulty) {
      case Difficulty.easy:
        return true;
      case Difficulty.medium:
        return level >= 5;
      case Difficulty.hard:
        return level >= 10;
    }
  }

  String _titleForCategory(CategoryType category) {
    switch (category) {
      case CategoryType.numbers:
        return 'Numbers';
      case CategoryType.letters:
        return 'Letters';
      case CategoryType.shapes:
        return 'Shapes';
      case CategoryType.colors:
        return 'Colors';
    }
  }
}

class _DifficultyCard extends StatefulWidget {
  final Difficulty difficulty;
  final VoidCallback? onTap;
  final bool locked;
  final String? lockMessage;

  const _DifficultyCard({
    required this.difficulty,
    this.onTap,
    this.locked = false,
    this.lockMessage,
  });

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard> {
  bool _pressed = false;
  static const double _iconSize = 52;

  @override
  Widget build(BuildContext context) {
    final config = _difficultyConfig(widget.difficulty);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.locked && widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.96 : 1,
        child: Stack(
          children: [
            Positioned.fill(
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: config.colors.first.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Opacity(
              opacity: widget.locked ? 0.55 : 1,
              child: Container(
                height: 110,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: config.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: _iconSize,
                      height: _iconSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          config.icon,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            config.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.locked
                                ? widget.lockMessage!
                                : config.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: _iconSize),
                  ],
                ),
              ),
            ),
            if (widget.locked)
              Positioned(
                right: 20,
                top: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

_DifficultyConfig _difficultyConfig(Difficulty d) {
  switch (d) {
    case Difficulty.easy:
      return _DifficultyConfig(
        label: 'Easy',
        subtitle: 'Let’s Warm Up!',
        icon: FontAwesomeIcons.star,
        colors: const [Color(0xFF6FCF97), Color(0xFFB7EFC5)],
      );
    case Difficulty.medium:
      return _DifficultyConfig(
        label: 'Medium',
        subtitle: 'Getting Tricky!',
        icon: FontAwesomeIcons.bolt,
        colors: const [Color(0xFFF2C94C), Color(0xFFF7E4A1)],
      );
    case Difficulty.hard:
      return _DifficultyConfig(
        label: 'Hard',
        subtitle: 'Challenge Time!',
        icon: FontAwesomeIcons.fire,
        colors: const [Color(0xFFEB5757), Color(0xFFF3A6A6)],
      );
  }
}

class _DifficultyConfig {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  _DifficultyConfig({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}

class _SoftDecor extends StatelessWidget {
  const _SoftDecor();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return IgnorePointer(
      child: Stack(
        children: [
          _bubble(top: 10, left: -50, size: 200, opacity: 0.14),
          _bubble(top: h * 0.15, right: -70, size: 160, opacity: 0.12),
          _bubble(bottom: -80, left: -50, size: 220, opacity: 0.14),
          _bubble(bottom: 140, right: -60, size: 140, opacity: 0.1),
        ],
      ),
    );
  }

  Widget _bubble({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF3A5BA0).withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

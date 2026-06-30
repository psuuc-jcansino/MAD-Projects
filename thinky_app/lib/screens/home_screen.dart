import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/category.dart';
import '../constants/prefs_keys.dart';
import '../models/kid_profile.dart';
import '../screens/difficulty_screen.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final KidProfile profile;

  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late KidProfile _profile;
  int _totalStars = 0;

  static const int starsPerLevel = 10;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _loadTotalStars();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  int get level => (_totalStars ~/ starsPerLevel) + 1;
  double get progress => (_totalStars % starsPerLevel) / starsPerLevel;

  Future<void> _loadTotalStars() async {
    final prefs = await SharedPreferences.getInstance();
    final starsKey = '${PrefKeys.totalStars}_${_profile.id}';
    final stars = prefs.getInt(starsKey) ?? 0;
    if (mounted) setState(() => _totalStars = stars);
  }

  Future<void> _openProfile() async {
    final updatedProfile = await Navigator.push<KidProfile>(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(profile: _profile)),
    );

    if (updatedProfile != null && mounted) {
      setState(() => _profile = updatedProfile);
      _loadTotalStars();
    }
  }

  void _openDifficulty(CategoryType category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DifficultyScreen(
          category: category,
          profile: _profile,
          totalStars: _totalStars,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _profile);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6EC6FF), Color(0xFFFFF4D8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _openProfile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'lib/assets/avatars/${_profile.avatar}',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back,",
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  _profile.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// ⭐ EMPHASIZED LEVEL INDICATOR
                          LevelIndicator(
                            level: level,
                            progress: progress,
                            animation: _starController,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 56,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context, _profile);
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.chevronLeft,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Let's Learn!",
                            style: GoogleFonts.fredoka(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                  color: Color(0x332C3E50),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    "Pick one and have fun!",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        CategoryCard(
                          title: "Numbers",
                          icon: FontAwesomeIcons.six,
                          gradient: const [
                            Color(0xFF5DADE2),
                            Color(0xFF85C1E9),
                          ],
                          iconLeft: true,
                          onTap: () => _openDifficulty(CategoryType.numbers),
                        ),
                        CategoryCard(
                          title: "Letters",
                          icon: FontAwesomeIcons.font,
                          gradient: const [
                            Color(0xFFAF7AC5),
                            Color(0xFFD2B4DE),
                          ],
                          iconLeft: false,
                          onTap: () => _openDifficulty(CategoryType.letters),
                        ),
                        CategoryCard(
                          title: "Shapes",
                          icon: FontAwesomeIcons.shapes,
                          gradient: const [
                            Color(0xFF58D68D),
                            Color(0xFF82E0AA),
                          ],
                          iconLeft: true,
                          onTap: () => _openDifficulty(CategoryType.shapes),
                        ),
                        CategoryCard(
                          title: "Colors",
                          icon: FontAwesomeIcons.palette,
                          gradient: const [
                            Color(0xFFF5B041),
                            Color(0xFFFAD7A0),
                          ],
                          iconLeft: false,
                          onTap: () => _openDifficulty(CategoryType.colors),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ⭐ STAR + BIG LEVEL TEXT
class LevelIndicator extends StatelessWidget {
  final int level;
  final double progress;
  final Animation<double> animation;

  const LevelIndicator({
    super.key,
    required this.level,
    required this.progress,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// LEFT: LEVEL TEXT + NUMBER
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "LEVEL",
              style: GoogleFonts.fredoka(
                fontSize: 11,
                letterSpacing: 1.2,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              level.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(width: 10),

        /// RIGHT: HALO + ROTATING STAR
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(48, 48),
                painter: _HaloPainter(progress),
              ),
              AnimatedBuilder(
                animation: animation,
                builder: (_, child) => Transform.rotate(
                  angle: animation.value * 2 * pi,
                  child: child,
                ),
                child: const Icon(
                  Icons.star,
                  size: 26,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🎯 HALO PAINTER
class _HaloPainter extends CustomPainter {
  final double progress;
  _HaloPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.0;
    final rect = Offset.zero & size;
    final startAngle = -pi / 2;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, 2 * pi, false, bgPaint);

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final bool iconLeft;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.iconLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 135,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: iconLeft ? -10 : null,
                  right: iconLeft ? null : -10,
                  top: -10,
                  child: FaIcon(
                    icon,
                    size: 150,
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                Align(
                  alignment: iconLeft
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: iconLeft ? 28 : 70,
                      right: iconLeft ? 70 : 28,
                    ),
                    child: Text(
                      title,
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

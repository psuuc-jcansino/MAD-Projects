import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kid_profile.dart';
import '../constants/prefs_keys.dart';
import '../screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final KidProfile profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late KidProfile _profile;
  int _totalStars = 0;
  static const int starsPerLevel = 10;

  String _mostPlayedCategory = 'N/A';
  String _favoriteDifficulty = 'N/A';

  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _loadProgressAndStats();

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

  Future<void> _loadProgressAndStats() async {
    final prefs = await SharedPreferences.getInstance();
    final profileId = _profile.id;

    final starsKey = '${PrefKeys.totalStars}_$profileId';
    final stars = prefs.getInt(starsKey) ?? 0;

    final categoryKey = 'category_counts_$profileId';
    final categoryList = prefs.getStringList(categoryKey) ?? [];

    String mostPlayed = 'N/A';
    if (categoryList.isNotEmpty) {
      final map = Map<String, int>.fromEntries(
        categoryList.map((e) {
          final parts = e.split(':');
          return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
        }),
      );
      final sorted = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostPlayed =
          sorted.first.key[0].toUpperCase() + sorted.first.key.substring(1);
    }

    final diffKey = 'difficulty_counts_$profileId';
    final diffList = prefs.getStringList(diffKey) ?? [];

    String favoriteDiff = 'N/A';
    if (diffList.isNotEmpty) {
      final map = Map<String, int>.fromEntries(
        diffList.map((e) {
          final parts = e.split(':');
          return MapEntry(parts[0], int.tryParse(parts[1]) ?? 0);
        }),
      );
      final sorted = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      favoriteDiff = sorted.first.key;
    }

    if (mounted) {
      setState(() {
        _totalStars = stars;
        _mostPlayedCategory = mostPlayed;
        _favoriteDifficulty = favoriteDiff;
      });
    }
  }

  int get level => (_totalStars ~/ starsPerLevel) + 1;
  double get progress => (_totalStars % starsPerLevel) / starsPerLevel;

  Color _difficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return const Color(0xFF6FCF97);
      case 'medium':
        return const Color(0xFFF2C94C);
      case 'hard':
        return const Color(0xFFEB5757);
      default:
        return Colors.grey;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'numbers':
        return const Color(0xFF5DADE2);
      case 'letters':
        return const Color(0xFFAF7AC5);
      case 'shapes':
        return const Color(0xFF58D68D);
      case 'colors':
        return const Color(0xFFF5B041);
      default:
        return Colors.grey;
    }
  }

  void _popWithProfile() {
    Navigator.pop(context, _profile);
  }

  @override
  Widget build(BuildContext context) {
    const double circleSize = 180;

    return WillPopScope(
      onWillPop: () async {
        _popWithProfile();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: _popWithProfile,
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),

                            Column(
                              children: [
                                Text(
                                  'Profile',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your learning journey',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  final updatedProfile =
                                      await Navigator.push<KidProfile>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditProfileScreen(
                                            profile: _profile,
                                          ),
                                        ),
                                      );

                                  if (updatedProfile != null && mounted) {
                                    setState(() => _profile = updatedProfile);
                                    _loadProgressAndStats();
                                  }
                                },
                                child: const FaIcon(
                                  FontAwesomeIcons.penToSquare,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  'lib/assets/avatars/${_profile.avatar}',
                                  width: 112,
                                  height: 112,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _profile.name,
                                style: GoogleFonts.fredoka(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Age ${_profile.age}',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          height: circleSize + 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(circleSize, circleSize),
                                painter: _HaloPainter(progress),
                              ),
                              AnimatedBuilder(
                                animation: _starController,
                                builder: (_, child) => Transform.rotate(
                                  angle: _starController.value * 2 * pi,
                                  child: child,
                                ),
                                child: const Icon(
                                  Icons.star,
                                  size: 130,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                              Positioned(
                                top: circleSize / 2 + 10,
                                child: Text(
                                  'Level $level',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        _StatCard(
                          title: 'Most Played Category',
                          value: _mostPlayedCategory,
                          valueColor: _categoryColor(_mostPlayedCategory),
                        ),
                        const SizedBox(height: 14),
                        _StatCard(
                          title: 'Favorite Difficulty',
                          value: _favoriteDifficulty,
                          valueColor: _difficultyColor(_favoriteDifficulty),
                        ),
                        const SizedBox(height: 14),
                        _StatCard(
                          title: 'Stars Collected',
                          value: _totalStars.toString(),
                          valueColor: const Color(0xFFFFD700),
                        ),
                      ],
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: valueColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
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

class _HaloPainter extends CustomPainter {
  final double progress;
  _HaloPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 18.0;
    final rect = Offset.zero & size;
    final startAngle = -pi / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      0,
      2 * pi,
      false,
      backgroundPaint,
    );
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      2 * pi * progress,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}

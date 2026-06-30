import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gekitou_app/screens/character_select_screen.dart';
import 'package:gekitou_app/screens/history_screen.dart';
import 'package:gekitou_app/widgets/painters.dart';
import 'package:gekitou_app/widgets/section_label.dart';
import 'package:gekitou_app/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/character_provider.dart';
import '../../providers/user_provider.dart';

class BattleEntry {
  final String opponentName;
  final String opponentCharacter;
  final bool isWin;
  final String difficulty;
  final int duration;
  final DateTime foughtAt;

  const BattleEntry({
    required this.opponentName,
    required this.opponentCharacter,
    required this.isWin,
    required this.difficulty,
    required this.duration,
    required this.foughtAt,
  });

  factory BattleEntry.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final ts = map['timestamp'];
    if (ts is Timestamp) {
      parsedDate = ts.toDate();
    } else if (ts is String) {
      parsedDate = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return BattleEntry(
      opponentName: (map['enemyCharacterName'] as String? ?? 'UNKNOWN')
          .toUpperCase(),
      opponentCharacter: map['enemyCharacterName'] as String? ?? '',
      isWin: map['playerWon'] as bool? ?? false,
      difficulty: map['difficulty'] as String? ?? 'normal',
      duration: map['totalMoves'] as int? ?? 0,
      foughtAt: parsedDate,
    );
  }
}

class _DifficultyTheme {
  final Color primary;
  final Color background;
  final Color glowTop;
  final String flavor;

  const _DifficultyTheme({
    required this.primary,
    required this.background,
    required this.glowTop,
    required this.flavor,
  });
}

const _kDifficultyThemes = {
  'easy': _DifficultyTheme(
    primary: Color(0xFF1D9E75),
    background: Color(0xFF090F0D),
    glowTop: Color(0xFF1D9E75),
    flavor: '"Take it easy, warrior."',
  ),
  'normal': _DifficultyTheme(
    primary: Color(0xFF7F77DD),
    background: Color(0xFF0C0E1A),
    glowTop: Color(0xFF7F77DD),
    flavor: '"Prove your worth."',
  ),
  'hard': _DifficultyTheme(
    primary: Color(0xFFE24B4A),
    background: Color(0xFF120A0A),
    glowTop: Color(0xFFE24B4A),
    flavor: '"No mercy. No retreat."',
  ),
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _selectedDifficulty = 'normal';

  bool _battlesLoaded = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeOpacity;
  late Animation<Offset> _fadeSlide;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  late AnimationController _scanlineController;
  late Animation<double> _scanlineAnim;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnim;

  late AnimationController _themeController;
  late Animation<Color?> _bgColorAnim;
  late Animation<Color?> _glowColorAnim;
  Color _prevBg = _kDifficultyThemes['normal']!.background;
  Color _prevGlow = _kDifficultyThemes['normal']!.glowTop;
  Color _targetBg = _kDifficultyThemes['normal']!.background;
  Color _targetGlow = _kDifficultyThemes['normal']!.glowTop;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );
    _fadeController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
    _scanlineAnim = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _scanlineController, curve: Curves.linear),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _themeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bgColorAnim = ColorTween(begin: _prevBg, end: _targetBg).animate(
      CurvedAnimation(parent: _themeController, curve: Curves.easeInOut),
    );
    _glowColorAnim = ColorTween(begin: _prevGlow, end: _targetGlow).animate(
      CurvedAnimation(parent: _themeController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CharacterProvider>(context, listen: false).fetchCharacters();
      _tryLoadBattles();
    });
  }

  void _tryLoadBattles() {
    if (_battlesLoaded) return;
    final uid = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser?.uid;
    if (uid != null) {
      _battlesLoaded = true;
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).loadBattleHistory(uid, limit: 10);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _scanlineController.dispose();
    _blinkController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  void _setDifficulty(String d) {
    if (d == _selectedDifficulty) return;
    final theme = _kDifficultyThemes[d]!;
    final current = _kDifficultyThemes[_selectedDifficulty]!;

    _prevBg = _bgColorAnim.value ?? current.background;
    _prevGlow = _glowColorAnim.value ?? current.glowTop;
    _targetBg = theme.background;
    _targetGlow = theme.glowTop;

    _bgColorAnim = ColorTween(begin: _prevBg, end: _targetBg).animate(
      CurvedAnimation(parent: _themeController, curve: Curves.easeInOut),
    );
    _glowColorAnim = ColorTween(begin: _prevGlow, end: _targetGlow).animate(
      CurvedAnimation(parent: _themeController, curve: Curves.easeInOut),
    );

    _themeController.forward(from: 0);
    setState(() => _selectedDifficulty = d);
  }

  void _startBattle() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterSelectScreen(difficulty: _selectedDifficulty),
      ),
    );
  }

  void _openBattleHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BattleHistoryScreen()));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF0F1120),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: const Color(0xFFE24B4A).withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    color: const Color(0xFFE24B4A),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RETREAT?',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your battle record will be saved.\nAre you sure you want to log out?',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.6),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.12),
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'STAY',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (mounted) {
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).logout();
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE24B4A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'LEAVE',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (!_battlesLoaded && authProvider.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoadBattles());
    }

    final user = authProvider.currentUser;
    final displayName =
        user?.displayName ?? user?.email.split('@')[0] ?? 'Warrior';
    final totalBattles = user?.totalBattles ?? 0;
    final wins = user?.wins ?? 0;
    final xpProgress = totalBattles == 0 ? 0.0 : (wins % 10) / 10.0;
    final level = (totalBattles / 10).floor() + 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final diffTheme = _kDifficultyThemes[_selectedDifficulty]!;

    final recentBattles = userProvider.battleHistory
        .map((m) => BattleEntry.fromMap(m))
        .toList();

    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        final currentBg = _bgColorAnim.value ?? diffTheme.background;
        final currentGlow = _glowColorAnim.value ?? diffTheme.glowTop;

        return Scaffold(
          backgroundColor: currentBg,
          body: Stack(
            children: [
              CustomPaint(
                painter: GridPainter(),
                size: MediaQuery.of(context).size,
              ),

              AnimatedBuilder(
                animation: _scanlineAnim,
                builder: (_, __) => Positioned(
                  top: MediaQuery.of(context).size.height * _scanlineAnim.value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          currentGlow.withOpacity(0.04),
                          currentGlow.withOpacity(0.08),
                          currentGlow.withOpacity(0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        currentGlow.withOpacity(0.20),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -120,
                left: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF1D9E75).withOpacity(0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                child: CustomPaint(
                  painter: DiagonalAccentPainter(),
                  size: const Size(200, 200),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        currentGlow.withOpacity(0.7),
                        currentGlow.withOpacity(0.9),
                        currentGlow.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fadeOpacity,
                  child: SlideTransition(
                    position: _fadeSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: diffTheme.primary
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            border: Border.all(
                                              color: diffTheme.primary
                                                  .withOpacity(0.35),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            'PLAYER',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2,
                                              color: diffTheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            displayName.toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Orbitron',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _blinkAnim,
                                    builder: (_, __) => Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(
                                              0xFF1D9E75,
                                            ).withOpacity(_blinkAnim.value),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'READY',
                                          style: TextStyle(
                                            fontSize: 9,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(
                                              0xFF1D9E75,
                                            ).withOpacity(_blinkAnim.value),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _handleLogout,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white.withOpacity(0.04),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.08),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        size: 16,
                                        color: Colors.white.withOpacity(0.35),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.06),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: diffTheme.primary.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: diffTheme.primary.withOpacity(
                                            0.4,
                                          ),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'LVL',
                                            style: TextStyle(
                                              fontSize: 7,
                                              letterSpacing: 1,
                                              color: Colors.white.withOpacity(
                                                0.35,
                                              ),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            '$level',
                                            style: TextStyle(
                                              fontFamily: 'Orbitron',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: diffTheme.primary,
                                              height: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'EXPERIENCE',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  letterSpacing: 2,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              Text(
                                                '${(xpProgress * 100).toInt()} / 100 XP',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  letterSpacing: 1,
                                                  color: Colors.white
                                                      .withOpacity(0.25),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Stack(
                                            children: [
                                              Container(
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.06),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              AnimatedBuilder(
                                                animation: _pulseAnim,
                                                builder: (_, __) => FractionallySizedBox(
                                                  widthFactor: xpProgress.clamp(
                                                    0.0,
                                                    1.0,
                                                  ),
                                                  child: Container(
                                                    height: 4,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          diffTheme.primary,
                                                          diffTheme.primary
                                                              .withOpacity(
                                                                _pulseAnim
                                                                    .value,
                                                              ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '$totalBattles battles fought',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              const AnimeSection(label: 'BATTLE RECORD'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  StatCard(
                                    value: '$totalBattles',
                                    label: 'BATTLES',
                                    color: const Color(0xFF7F77DD),
                                  ),
                                  const SizedBox(width: 8),
                                  StatCard(
                                    value: '$wins',
                                    label: 'WINS',
                                    color: const Color(0xFF1D9E75),
                                  ),
                                  const SizedBox(width: 8),
                                  StatCard(
                                    value: '${user?.losses ?? 0}',
                                    label: 'LOSSES',
                                    color: const Color(0xFFE24B4A),
                                  ),
                                  const SizedBox(width: 8),
                                  StatCard(
                                    value:
                                        '${user?.getWinRate().toStringAsFixed(1) ?? '0.0'}%',
                                    label: 'RATE',
                                    color: const Color(0xFFE8A838),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              const AnimeSection(label: 'SELECT DIFFICULTY'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DifficultyTile(
                                      label: 'EASY',
                                      sublabel: 'RELAXED',
                                      icon:
                                          Icons.sentiment_satisfied_alt_rounded,
                                      color: const Color(0xFF1D9E75),
                                      isSelected: _selectedDifficulty == 'easy',
                                      onTap: () => _setDifficulty('easy'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _DifficultyTile(
                                      label: 'NORMAL',
                                      sublabel: 'BALANCED',
                                      icon: Icons.bolt_rounded,
                                      color: const Color(0xFF7F77DD),
                                      isSelected:
                                          _selectedDifficulty == 'normal',
                                      onTap: () => _setDifficulty('normal'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _DifficultyTile(
                                      label: 'HARD',
                                      sublabel: 'BRUTAL',
                                      icon: Icons.local_fire_department_rounded,
                                      color: const Color(0xFFE24B4A),
                                      isSelected: _selectedDifficulty == 'hard',
                                      onTap: () => _setDifficulty('hard'),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                        opacity: anim,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.3),
                                            end: Offset.zero,
                                          ).animate(anim),
                                          child: child,
                                        ),
                                      ),
                                  child: Text(
                                    diffTheme.flavor,
                                    key: ValueKey(_selectedDifficulty),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: diffTheme.primary.withOpacity(0.5),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              _AnimatedStartButton(
                                color: diffTheme.primary,
                                pulseAnim: _pulseAnim,
                                onTap: _startBattle,
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton(
                                  onPressed: _openBattleHistory,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white.withOpacity(
                                      0.45,
                                    ),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.08),
                                      width: 0.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history_rounded,
                                        size: 15,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'BATTLE HISTORY',
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              const AnimeSection(label: 'RECENT BATTLES'),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),

                        Expanded(
                          child: userProvider.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: diffTheme.primary,
                                    strokeWidth: 1.5,
                                  ),
                                )
                              : recentBattles.isEmpty
                              ? Center(
                                  child: Text(
                                    'NO BATTLES YET',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 2,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    bottomPadding + 20,
                                  ),
                                  itemCount: recentBattles.length,
                                  itemBuilder: (_, i) =>
                                      _BattleEntryRow(entry: recentBattles[i]),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DifficultyTile extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DifficultyTile> createState() => _DifficultyTileState();
}

class _DifficultyTileState extends State<_DifficultyTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    if (widget.isSelected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_DifficultyTile old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward();
    } else if (!widget.isSelected && old.isSelected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withOpacity(0.15)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.isSelected
                  ? widget.color.withOpacity(0.55)
                  : Colors.white.withOpacity(0.07),
              width: widget.isSelected ? 1.0 : 0.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? widget.color.withOpacity(0.20)
                      : Colors.white.withOpacity(0.05),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isSelected
                      ? widget.color
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 350),
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: widget.isSelected
                      ? widget.color
                      : Colors.white.withOpacity(0.5),
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 3),
              Text(
                widget.sublabel,
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? widget.color.withOpacity(0.55)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedStartButton extends StatelessWidget {
  final Color color;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const _AnimatedStartButton({
    required this.color,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Align(
                    alignment: Alignment(-1.5 + pulseAnim.value * 3.0, 0),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_kabaddi_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'ENTER BATTLE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: Colors.white,
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
}

class _BattleEntryRow extends StatelessWidget {
  final BattleEntry entry;

  const _BattleEntryRow({required this.entry});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _formatDuration(int moves) {
    return '$moves moves';
  }

  Color get _diffColor {
    switch (entry.difficulty) {
      case 'easy':
        return const Color(0xFF1D9E75);
      case 'hard':
        return const Color(0xFFE24B4A);
      default:
        return const Color(0xFF7F77DD);
    }
  }

  @override
  Widget build(BuildContext context) {
    const winColor = Color(0xFF1D9E75);
    const lossColor = Color(0xFFE24B4A);
    final outcomeColor = entry.isWin ? winColor : lossColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: outcomeColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: outcomeColor.withOpacity(0.8)),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: outcomeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: outcomeColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            entry.isWin ? 'W' : 'L',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: outcomeColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.opponentName,
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  entry.opponentCharacter,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.35),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDuration(entry.duration),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.25),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _diffColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: _diffColor.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              entry.difficulty.toUpperCase(),
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: _diffColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _timeAgo(entry.foughtAt),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withOpacity(0.2),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

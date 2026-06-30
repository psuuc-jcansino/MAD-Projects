import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gekitou_app/screens/history_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/painters.dart';
import 'home_screen.dart';

extension _SafeOpacity on Color {
  Color op(double v) => withOpacity(v.clamp(0.0, 1.0));
}

class _BurstParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  double progress = 0.0;

  _BurstParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  Offset position(double maxRadius) {
    final dist = progress * speed * maxRadius;
    return Offset(cos(angle) * dist, sin(angle) * dist);
  }
}

class _BurstPainter extends CustomPainter {
  final List<_BurstParticle> particles;
  final Offset center;
  const _BurstPainter(this.particles, this.center);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final opacity = (1.0 - p.progress).clamp(0.0, 1.0);
      final pos = center + p.position(size.shortestSide * 0.6);
      canvas.drawCircle(
        pos,
        p.size * (1 - p.progress * 0.5),
        Paint()..color = p.color.withOpacity(opacity * 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => true;
}

class BattleResultScreen extends StatefulWidget {
  final Map<String, dynamic> battleResult;

  const BattleResultScreen({Key? key, required this.battleResult})
    : super(key: key);

  @override
  State<BattleResultScreen> createState() => _BattleResultScreenState();
}

class _BattleResultScreenState extends State<BattleResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final AnimationController _scanCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  )..repeat();
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  late final AnimationController _blinkCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final AnimationController _resultCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _statsCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _burstCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final AnimationController _particleTickCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Animation<double> _fadeOpacity = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

  late final Animation<double> _scanAnim = Tween<double>(
    begin: -0.1,
    end: 1.1,
  ).animate(CurvedAnimation(parent: _scanCtrl, curve: Curves.linear));

  late final Animation<double> _pulseAnim = Tween<double>(
    begin: 0.5,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  late final Animation<double> _blinkAnim = Tween<double>(
    begin: 0.2,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut));

  late final Animation<double> _resultScale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 3),
    TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _resultCtrl, curve: Curves.easeOut));

  late final Animation<double> _resultOpacity = Tween<double>(begin: 0, end: 1)
      .animate(
        CurvedAnimation(
          parent: _resultCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        ),
      );

  late final Animation<Offset> _statsSlide = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOutCubic));

  late final Animation<double> _statsOpacity = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut));

  late final Animation<double> _glowAnim = Tween<double>(
    begin: 0.4,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

  final List<_BurstParticle> _particles = [];
  final Random _rng = Random();

  bool get _isWin => widget.battleResult['playerWon'] ?? false;
  Color get _primaryColor =>
      _isWin ? const Color(0xFF1D9E75) : const Color(0xFFE24B4A);
  Color get _accentColor =>
      _isWin ? const Color(0xFF7F77DD) : const Color(0xFFE8A838);

  @override
  void initState() {
    super.initState();
    _particleTickCtrl.addListener(_tickParticles);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveBattleResult();
      _playEntrance();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _blinkCtrl.dispose();
    _resultCtrl.dispose();
    _statsCtrl.dispose();
    _burstCtrl.dispose();
    _glowCtrl.dispose();
    _particleTickCtrl
      ..removeListener(_tickParticles)
      ..dispose();
    super.dispose();
  }

  Future<void> _saveBattleResult() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final result = Map<String, dynamic>.from(widget.battleResult);
      result['battleId'] ??= DateTime.now().millisecondsSinceEpoch.toString();

      await userProvider.saveBattleResult(
        authProvider.currentUser!.uid,
        result,
      );

      await authProvider.refreshUser();
    }
  }

  Future<void> _playEntrance() async {
    HapticFeedback.heavyImpact();
    _spawnBurst();
    await _resultCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _statsCtrl.forward();
    _fadeCtrl.forward();
  }

  void _spawnBurst() {
    setState(() {
      for (int i = 0; i < 28; i++) {
        _particles.add(
          _BurstParticle(
            angle: _rng.nextDouble() * 2 * pi,
            speed: 0.3 + _rng.nextDouble() * 0.7,
            size: 2.0 + _rng.nextDouble() * 4.0,
            color: _rng.nextBool() ? _primaryColor : _accentColor,
          ),
        );
      }
    });
    _burstCtrl.forward(from: 0);
  }

  void _tickParticles() {
    if (_particles.isEmpty) return;
    setState(() {
      for (final p in _particles) {
        p.progress = (p.progress + 0.018).clamp(0.0, 1.0);
      }
      _particles.removeWhere((p) => p.progress >= 1.0);
    });
  }

  void _backToHome() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _viewHistory() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BattleHistoryScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final enemyName = widget.battleResult['enemyCharacterName'] ?? 'Unknown';
    final finalMessage = widget.battleResult['battleEndReason'] ?? '';
    final playerFinalHp = widget.battleResult['playerFinalHp'] ?? 0;
    final totalMoves = widget.battleResult['totalMoves'] ?? 0;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0E1A),
        body: Stack(
          children: [
            CustomPaint(painter: GridPainter(), size: size),

            if (_particles.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _burstCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _BurstPainter(
                        List.from(_particles),
                        Offset(size.width / 2, size.height * 0.32),
                      ),
                      size: size,
                    ),
                  ),
                ),
              ),

            AnimatedBuilder(
              animation: _scanAnim,
              builder: (_, __) => Positioned(
                top: size.height * _scanAnim.value,
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
                        const Color(0xFF7F77DD).op(0.04),
                        const Color(0xFF7F77DD).op(0.07),
                        const Color(0xFF7F77DD).op(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Stack(
                children: [
                  Positioned(
                    top: -80,
                    right: -80,
                    child: _Orb(
                      size: 320,
                      color: _primaryColor,
                      opacity: 0.18 * _pulseAnim.value,
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -80,
                    child: _Orb(
                      size: 280,
                      color: _accentColor,
                      opacity: 0.12 * _pulseAnim.value,
                    ),
                  ),
                ],
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

            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: bottomPadding + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    _TopBar(
                      isWin: _isWin,
                      primaryColor: _primaryColor,
                      blinkAnim: _blinkAnim,
                    ),

                    const SizedBox(height: 32),

                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _resultCtrl,
                        _glowCtrl,
                        _pulseAnim,
                      ]),
                      builder: (_, __) => Center(
                        child: Transform.scale(
                          scale: _resultScale.value,
                          child: Opacity(
                            opacity: _resultOpacity.value.clamp(0.0, 1.0),
                            child: _ResultHero(
                              isWin: _isWin,
                              primaryColor: _primaryColor,
                              accentColor: _accentColor,
                              glowIntensity: _glowAnim.value,
                              pulseValue: _pulseAnim.value,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (finalMessage.isNotEmpty)
                      FadeTransition(
                        opacity: _statsOpacity,
                        child: Center(
                          child: Text(
                            '"$finalMessage"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.25),
                              letterSpacing: 0.5,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    SlideTransition(
                      position: _statsSlide,
                      child: FadeTransition(
                        opacity: _statsOpacity,
                        child: _StatsCard(
                          enemyName: enemyName,
                          playerFinalHp: playerFinalHp,
                          totalMoves: totalMoves,
                          primaryColor: _primaryColor,
                          pulseAnim: _pulseAnim,
                          isWin: _isWin,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    FadeTransition(
                      opacity: _fadeOpacity,
                      child: Column(
                        children: [
                          _PrimaryActionButton(
                            label: 'BACK TO HOME',
                            sublabel: 'RETURN TO BASE',
                            icon: Icons.home_rounded,
                            color: _primaryColor,
                            pulseAnim: _pulseAnim,
                            onTap: _backToHome,
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: _viewHistory,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white.withOpacity(0.45),
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
                                    'VIEW HISTORY',
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isWin;
  final Color primaryColor;
  final Animation<double> blinkAnim;

  const _TopBar({
    required this.isWin,
    required this.primaryColor,
    required this.blinkAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            'BATTLE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'RESULT',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        AnimatedBuilder(
          animation: blinkAnim,
          builder: (_, __) => Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(blinkAnim.value),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isWin ? 'VICTORY' : 'DEFEAT',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: primaryColor.withOpacity(blinkAnim.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultHero extends StatelessWidget {
  final bool isWin;
  final Color primaryColor;
  final Color accentColor;
  final double glowIntensity;
  final double pulseValue;

  const _ResultHero({
    required this.isWin,
    required this.primaryColor,
    required this.accentColor,
    required this.glowIntensity,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35 * glowIntensity),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.15 + 0.2 * pulseValue),
                  width: 1,
                ),
              ),
            ),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3 + 0.2 * pulseValue),
                  width: 0.5,
                ),
              ),
            ),
            Icon(
              isWin ? Icons.emoji_events_rounded : Icons.shield_rounded,
              size: 52,
              color: primaryColor,
            ),
            Positioned(
              top: 0,
              left: 130 / 2 - 60.0,
              child: Container(
                width: 14,
                height: 1,
                color: primaryColor.withOpacity(0.5),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 130 / 2 - 60.0,
              child: Container(
                width: 14,
                height: 1,
                color: primaryColor.withOpacity(0.5),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            isWin ? 'VICTORY' : 'DEFEAT',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          isWin ? 'BATTLE WON' : 'BATTLE LOST',
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String enemyName;
  final dynamic playerFinalHp;
  final dynamic totalMoves;
  final Color primaryColor;
  final Animation<double> pulseAnim;
  final bool isWin;

  const _StatsCard({
    required this.enemyName,
    required this.playerFinalHp,
    required this.totalMoves,
    required this.primaryColor,
    required this.pulseAnim,
    required this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.07),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(width: 3, height: 14, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'BATTLE STATS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _StatRow(
                  label: 'OPPONENT',
                  value: enemyName.toUpperCase(),
                  color: const Color(0xFFE24B4A),
                  pulseAnim: pulseAnim,
                ),
                _Divider(),
                _StatRow(
                  label: 'FINAL HP',
                  value: '$playerFinalHp / 100',
                  color: playerFinalHp is int && playerFinalHp > 50
                      ? const Color(0xFF1D9E75)
                      : playerFinalHp is int && playerFinalHp > 25
                      ? const Color(0xFFE8A838)
                      : const Color(0xFFE24B4A),
                  pulseAnim: pulseAnim,
                ),
                _Divider(),
                _StatRow(
                  label: 'TOTAL MOVES',
                  value: '$totalMoves',
                  color: const Color(0xFF7F77DD),
                  pulseAnim: pulseAnim,
                ),
                _Divider(),
                _StatRow(
                  label: 'OUTCOME',
                  value: isWin ? 'WIN' : 'LOSS',
                  color: primaryColor,
                  pulseAnim: pulseAnim,
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white.withOpacity(0.06),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Animation<double> pulseAnim;
  final bool highlight;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.pulseAnim,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Container(
            padding: highlight
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                : EdgeInsets.zero,
            decoration: highlight
                ? BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: color.withOpacity(0.2 + 0.2 * pulseAnim.value),
                      width: 0.5,
                    ),
                  )
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: highlight ? 12 : 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  State<_PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<_PrimaryActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: widget.pulseAnim,
        builder: (_, __) => Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _pressed
                    ? widget.color.withOpacity(0.25)
                    : widget.color.withOpacity(0.15),
                border: Border.all(
                  color: _pressed
                      ? widget.color.withOpacity(0.7)
                      : widget.color.withOpacity(
                          0.3 + 0.2 * widget.pulseAnim.value,
                        ),
                  width: _pressed ? 1.0 : 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(
                      (_pressed ? 0.35 : 0.15) * widget.pulseAnim.value,
                    ),
                    blurRadius: _pressed ? 20 : 12,
                    spreadRadius: _pressed ? 2 : 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 18, color: widget.color),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: widget.color,
                        ),
                      ),
                      Text(
                        widget.sublabel,
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: widget.color.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: _pressed ? 2 : 1.5,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(_pressed ? 1.0 : 0.7),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Orb({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withOpacity(opacity.clamp(0.0, 1.0)),
          Colors.transparent,
        ],
      ),
    ),
  );
}

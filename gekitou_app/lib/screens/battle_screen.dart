import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/character_model.dart';
import '../models/battle_model.dart';
import '../providers/battle_provider.dart';
import 'battle_result_screen.dart';

extension _SafeOpacity on Color {
  Color op(double v) => withOpacity(v.clamp(0.0, 1.0));
}

const _kPurple = Color(0xFF7F77DD);
const _kRed = Color(0xFFE24B4A);
const _kGreen = Color(0xFF1D9E75);
const _kGold = Color(0xFFFFD700);
const _kBg = Color(0xFF0C0E1A);

class _FloatingNumber {
  final String text;
  final Color color;
  final bool isEnemy;
  final String id;
  const _FloatingNumber({
    required this.text,
    required this.color,
    required this.isEnemy,
    required this.id,
  });
}

class _SlashParticle {
  final Offset start;
  final Offset end;
  final double thickness;
  final Color color;
  double progress = 0;
  _SlashParticle({
    required this.start,
    required this.end,
    required this.thickness,
    required this.color,
  });
}

class _FighterAnims {
  final AnimationController flash;
  final AnimationController shake;
  final AnimationController lunge;

  Animation<double> get flashAnim => flash.view;
  Animation<double> get shakeAnim => _shakeSeq(shake);
  Animation<double> get lungeAnim => TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(parent: lunge, curve: Curves.easeInOut));

  _FighterAnims({required TickerProvider vsync})
    : flash = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 350),
      ),
      shake = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 400),
      ),
      lunge = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 280),
      );

  void dispose() {
    flash.dispose();
    shake.dispose();
    lunge.dispose();
  }

  static Animation<double> _shakeSeq(AnimationController c) =>
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -12.0, end: 14.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 14.0, end: -10.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.linear));
}

class _GridPainter extends CustomPainter {
  const _GridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 40)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _DiagonalAccentPainter extends CustomPainter {
  const _DiagonalAccentPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _kPurple.withOpacity(0.07)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 6; i++) {
      final o = i * 18.0;
      canvas.drawLine(Offset(o, 0), Offset(0, o), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _ArenaSplitPainter extends CustomPainter {
  const _ArenaSplitPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width / 2 - 10, 0),
      Offset(size.width / 2 + 10, size.height),
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _SlashPainter extends CustomPainter {
  final List<_SlashParticle> particles;
  const _SlashPainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final opacity = (1.0 - p.progress).clamp(0.0, 1.0);
      final w = p.thickness * (1 - p.progress * 0.6);
      canvas.drawLine(
        p.start,
        p.end,
        Paint()
          ..color = p.color.op(opacity * 0.9)
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        p.start,
        p.end,
        Paint()
          ..color = Colors.white.op(opacity * 0.4)
          ..strokeWidth = w * 0.3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_SlashPainter _) => true;
}

class _SilhouettePainter extends CustomPainter {
  final Color color;
  final bool isPlayer;
  const _SilhouettePainter({required this.color, required this.isPlayer});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color.withOpacity(0.80);
    final glow = Paint()
      ..color = color.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    final accent = Paint()..color = color.withOpacity(0.55);
    final cx = size.width / 2;
    final h = size.height;
    canvas.drawCircle(Offset(cx, h * 0.36), 26, glow);
    void poly(List<Offset> pts, [Paint? p]) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final o in pts.skip(1)) path.lineTo(o.dx, o.dy);
      path.close();
      canvas.drawPath(path, p ?? fill);
    }

    if (isPlayer) {
      canvas.drawCircle(Offset(cx - 1, h * 0.13), 9.5, fill);
      poly([
        Offset(cx - 1, h * .02),
        Offset(cx - 4, h * .10),
        Offset(cx + 2, h * .10),
      ], accent);
      poly([
        Offset(cx - 9, h * .24),
        Offset(cx + 8, h * .24),
        Offset(cx + 10, h * .52),
        Offset(cx - 11, h * .52),
      ]);
      poly([
        Offset(cx - 9, h * .26),
        Offset(cx - 28, h * .20),
        Offset(cx - 32, h * .38),
        Offset(cx - 12, h * .44),
      ]);
      poly([
        Offset(cx - 30, h * .21),
        Offset(cx - 36, h * .24),
        Offset(cx - 38, h * .38),
        Offset(cx - 32, h * .44),
        Offset(cx - 26, h * .42),
        Offset(cx - 24, h * .30),
      ], accent);
      poly([
        Offset(cx + 8, h * .26),
        Offset(cx + 26, h * .18),
        Offset(cx + 30, h * .26),
        Offset(cx + 12, h * .38),
      ]);
      poly([
        Offset(cx + 28, h * .08),
        Offset(cx + 32, h * .12),
        Offset(cx + 22, h * .28),
        Offset(cx + 18, h * .24),
      ], accent);
      poly([
        Offset(cx - 11, h * .52),
        Offset(cx - 2, h * .52),
        Offset(cx - 3, h * .82),
        Offset(cx - 14, h * .84),
      ]);
      poly([
        Offset(cx + 2, h * .52),
        Offset(cx + 10, h * .52),
        Offset(cx + 16, h * .82),
        Offset(cx + 4, h * .84),
      ]);
      poly([
        Offset(cx - 14, h * .82),
        Offset(cx - 3, h * .82),
        Offset(cx - 2, h * .92),
        Offset(cx - 16, h * .92),
      ], accent);
      poly([
        Offset(cx + 4, h * .82),
        Offset(cx + 16, h * .82),
        Offset(cx + 18, h * .92),
        Offset(cx + 5, h * .92),
      ], accent);
    } else {
      canvas.drawCircle(Offset(cx, h * 0.14), 10.0, fill);
      poly([
        Offset(cx - 8, h * .07),
        Offset(cx - 14, h * .00),
        Offset(cx - 4, h * .10),
      ], accent);
      poly([
        Offset(cx + 8, h * .07),
        Offset(cx + 14, h * .00),
        Offset(cx + 4, h * .10),
      ], accent);
      poly([
        Offset(cx - 12, h * .24),
        Offset(cx + 12, h * .24),
        Offset(cx + 14, h * .54),
        Offset(cx - 14, h * .54),
      ]);
      poly([
        Offset(cx - 12, h * .27),
        Offset(cx - 34, h * .34),
        Offset(cx - 32, h * .44),
        Offset(cx - 10, h * .40),
      ]);
      poly([
        Offset(cx - 34, h * .34),
        Offset(cx - 40, h * .30),
        Offset(cx - 36, h * .38),
      ], accent);
      poly([
        Offset(cx - 34, h * .36),
        Offset(cx - 42, h * .36),
        Offset(cx - 36, h * .42),
      ], accent);
      poly([
        Offset(cx + 12, h * .27),
        Offset(cx + 32, h * .16),
        Offset(cx + 28, h * .26),
        Offset(cx + 10, h * .38),
      ]);
      poly([
        Offset(cx + 30, h * .16),
        Offset(cx + 38, h * .10),
        Offset(cx + 34, h * .20),
      ], accent);
      poly([
        Offset(cx - 14, h * .54),
        Offset(cx - 3, h * .54),
        Offset(cx - 5, h * .82),
        Offset(cx - 16, h * .84),
      ]);
      poly([
        Offset(cx + 3, h * .54),
        Offset(cx + 14, h * .54),
        Offset(cx + 18, h * .82),
        Offset(cx + 6, h * .84),
      ]);
      poly([
        Offset(cx - 16, h * .82),
        Offset(cx - 5, h * .82),
        Offset(cx - 4, h * .92),
        Offset(cx - 20, h * .92),
      ], accent);
      poly([
        Offset(cx + 6, h * .82),
        Offset(cx + 18, h * .82),
        Offset(cx + 22, h * .92),
        Offset(cx + 8, h * .92),
      ], accent);
    }
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) =>
      old.color != color || old.isPlayer != isPlayer;
}

class _ScreenShaker extends StatelessWidget {
  final Widget child;
  final Animation<double> shakeAnim;
  const _ScreenShaker({required this.child, required this.shakeAnim});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: shakeAnim,
    builder: (_, c) =>
        Transform.translate(offset: Offset(shakeAnim.value, 0), child: c),
    child: child,
  );
}

class BattleScreen extends StatefulWidget {
  final Character enemyCharacter;
  final Character? playerCharacter;

  const BattleScreen({
    Key? key,
    required this.enemyCharacter,
    this.playerCharacter,
  }) : super(key: key);

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  AnimationController _ctrl(int ms, {bool repeat = false, bool rev = false}) {
    final c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    );
    if (repeat) c.repeat(reverse: rev);
    return c;
  }

  Animation<double> _lerp(
    AnimationController c,
    double a,
    double b, {
    Curve curve = Curves.easeInOut,
  }) => Tween<double>(
    begin: a,
    end: b,
  ).animate(CurvedAnimation(parent: c, curve: curve));

  late final _fadeCtrl = _ctrl(500);
  late final _scanCtrl = _ctrl(3500, repeat: true);
  late final _pulseCtrl = _ctrl(2000, repeat: true, rev: true);
  late final _blinkCtrl = _ctrl(900, repeat: true, rev: true);
  late final _breatheCtrl = _ctrl(2800, repeat: true, rev: true);
  late final _introCtrl = _ctrl(1200);
  late final _screenShakeCtrl = _ctrl(500);
  late final _burstCtrl = _ctrl(600);
  late final _vignetteCtrl = _ctrl(1500, repeat: true, rev: true);
  late final _heartbeatCtrl = _ctrl(500, repeat: true, rev: true);
  late final _roundCtrl = _ctrl(800);
  late final _turnBannerCtrl = _ctrl(600);
  late final _slashCtrl = _ctrl(1000)..repeat();

  late final _fadeOpacity = _lerp(_fadeCtrl, 0, 1, curve: Curves.easeOut);
  late final _fadeSlide = Tween<Offset>(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
  late final _scanAnim = _lerp(_scanCtrl, -0.1, 1.1, curve: Curves.linear);
  late final _pulseAnim = _lerp(_pulseCtrl, 0.5, 1.0);
  late final _blinkAnim = _lerp(_blinkCtrl, 0.2, 1.0);
  late final _breatheScale = _lerp(_breatheCtrl, 1.0, 1.04);
  late final _breatheBob = _lerp(_breatheCtrl, 0.0, 6.0);

  late final _enemyIntroSlide =
      Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _introCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
        ),
      );
  late final _playerIntroSlide =
      Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _introCtrl,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
        ),
      );
  late final _fightTextAnim = _lerp(
    _introCtrl,
    0,
    1,
    curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
  );

  late final _screenShakeAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _screenShakeCtrl, curve: Curves.linear));

  late final _burstAnim = _lerp(_burstCtrl, 0, 1, curve: Curves.easeOut);
  late final _vignetteAnim = _lerp(_vignetteCtrl, 0, 1);
  late final _heartbeatAnim = _lerp(_heartbeatCtrl, 0, 1);
  late final _roundAnim = _lerp(_roundCtrl, 0, 1, curve: Curves.elasticOut);
  late final _turnBannerSlide =
      Tween<Offset>(begin: const Offset(-1.2, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _turnBannerCtrl, curve: Curves.easeOutBack),
      );
  late final _turnBannerOpacity = _lerp(
    _turnBannerCtrl,
    0,
    1,
    curve: Curves.easeOut,
  );

  late final _enemy = _FighterAnims(vsync: this);
  late final _player = _FighterAnims(vsync: this);

  bool _introComplete = false;
  bool _showCritical = false;
  String _criticalText = 'CRITICAL!';
  bool _showRound = false;
  int _roundNumber = 1;
  bool _showTurnBanner = false;
  String _turnBannerText = '';
  bool _lastKnownPlayerTurn = true;
  double _enemyHpFlash = 0.0;
  double _playerHpFlash = 0.0;
  double _orbIntensity = 1.0;
  int _prevPlayerHp = -1;
  int _prevEnemyHp = -1;
  int _prevMoveCount = 0;

  final List<_FloatingNumber> _floatingNumbers = [];
  final List<_SlashParticle> _slashParticles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _slashCtrl.addListener(_tickSlash);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final playerChar =
          widget.playerCharacter ??
          Character(
            id: '1',
            name: 'You',
            popularity: 1,
            hp: 100,
            attack: 15,
            defense: 10,
            speed: 12,
            difficulty: 'normal',
          );
      Provider.of<BattleProvider>(context, listen: false).initiateBattle(
        playerCharacter: playerChar,
        enemyCharacter: widget.enemyCharacter,
      );
      _playIntro();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _fadeCtrl,
      _scanCtrl,
      _pulseCtrl,
      _blinkCtrl,
      _breatheCtrl,
      _introCtrl,
      _screenShakeCtrl,
      _burstCtrl,
      _vignetteCtrl,
      _heartbeatCtrl,
      _roundCtrl,
      _turnBannerCtrl,
    ]) {
      c.dispose();
    }
    _slashCtrl
      ..removeListener(_tickSlash)
      ..dispose();
    _enemy.dispose();
    _player.dispose();
    super.dispose();
  }

  void _tickSlash() {
    if (_slashParticles.isEmpty) return;
    setState(() {
      for (final p in _slashParticles)
        p.progress = (p.progress + 0.045).clamp(0.0, 1.0);
      _slashParticles.removeWhere((p) => p.progress >= 1.0);
    });
  }

  void _spawnSlash({required bool atEnemy}) {
    if (!mounted) return;
    final sz = MediaQuery.of(context).size;
    final cx = atEnemy ? sz.width * 0.75 : sz.width * 0.25;
    final cy = sz.height * 0.30;
    final color = atEnemy ? _kRed : _kPurple;
    setState(() {
      for (int i = 0; i < 5; i++) {
        final angle = _rng.nextDouble() * pi - pi / 2;
        final len = 28.0 + _rng.nextDouble() * 40;
        _slashParticles.add(
          _SlashParticle(
            start: Offset(cx + cos(angle) * 4, cy + sin(angle) * 4),
            end: Offset(cx + cos(angle) * len, cy + sin(angle) * len),
            thickness: 1.5 + _rng.nextDouble() * 2.5,
            color: color,
          ),
        );
      }
    });
  }

  Future<void> _playIntro() async {
    await _introCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _introComplete = true);
    _fadeCtrl.forward();
  }

  Future<void> _showTurnTransition(bool isPlayerTurn) async {
    if (!mounted) return;
    setState(() {
      _turnBannerText = isPlayerTurn ? 'YOUR TURN' : 'ENEMY TURN';
      _showTurnBanner = true;
    });
    await _turnBannerCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await _turnBannerCtrl.reverse();
    if (mounted) setState(() => _showTurnBanner = false);
  }

  void _checkHpChanges(BattleState battle) {
    if (_prevEnemyHp == -1) {
      _prevEnemyHp = battle.enemyHp;
      _prevPlayerHp = battle.playerHp;
      _lastKnownPlayerTurn = battle.isPlayerTurn;
      return;
    }
    if (battle.isPlayerTurn != _lastKnownPlayerTurn) {
      _lastKnownPlayerTurn = battle.isPlayerTurn;
      _showTurnTransition(battle.isPlayerTurn);
    }
    final enemyDmg = _prevEnemyHp - battle.enemyHp;
    final playerDmg = _prevPlayerHp - battle.playerHp;
    final playerHealed = battle.playerHp - _prevPlayerHp;

    if (enemyDmg > 0) {
      final isCrit = enemyDmg > 20;
      _spawnFloatingNumber(
        isCrit ? '-$enemyDmg !!!' : '-$enemyDmg',
        isCrit ? _kGold : _kRed,
        true,
      );
      _enemy.flash.forward(from: 0);
      _enemy.shake.forward(from: 0);
      _spawnSlash(atEnemy: true);
      if (isCrit) {
        _screenShakeCtrl.forward(from: 0);
        HapticFeedback.heavyImpact();
        _triggerBurst('CRITICAL!');
      } else {
        HapticFeedback.mediumImpact();
      }
      _flashHpBar(isEnemy: true);
    }
    if (playerDmg > 0) {
      _spawnFloatingNumber('-$playerDmg', _kRed, false);
      _player.flash.forward(from: 0);
      _player.shake.forward(from: 0);
      _spawnSlash(atEnemy: false);
      HapticFeedback.mediumImpact();
      final pct = battle.playerHp / battle.playerMaxHp;
      setState(
        () => _orbIntensity = pct < 0.25
            ? 2.5
            : pct < 0.5
            ? 1.5
            : 1.0,
      );
      _flashHpBar(isEnemy: false);
    }
    if (playerHealed > 0) {
      _spawnFloatingNumber('+$playerHealed HP', _kGreen, false);
      HapticFeedback.lightImpact();
      _triggerBurst('HEALED!');
    }
    if (battle.moves.length > _prevMoveCount && battle.moves.length % 2 == 0) {
      setState(() {
        _roundNumber = (battle.moves.length ~/ 2) + 1;
        _showRound = true;
      });
      _roundCtrl.forward(from: 0);
      Future.delayed(
        const Duration(milliseconds: 1400),
        () => mounted ? setState(() => _showRound = false) : null,
      );
    }
    _prevEnemyHp = battle.enemyHp;
    _prevPlayerHp = battle.playerHp;
    _prevMoveCount = battle.moves.length;
  }

  void _flashHpBar({required bool isEnemy}) {
    setState(() => isEnemy ? _enemyHpFlash = 1.0 : _playerHpFlash = 1.0);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted)
        setState(() => isEnemy ? _enemyHpFlash = 0.0 : _playerHpFlash = 0.0);
    });
  }

  void _triggerBurst(String text) {
    setState(() {
      _showCritical = true;
      _criticalText = text;
    });
    _burstCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _showCritical = false);
    });
  }

  void _spawnFloatingNumber(String text, Color color, bool isEnemy) {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(9999)}';
    setState(
      () => _floatingNumbers.add(
        _FloatingNumber(text: text, color: color, isEnemy: isEnemy, id: id),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted)
        setState(() => _floatingNumbers.removeWhere((n) => n.id == id));
    });
  }

  Future<void> _handleAction(
    BattleAction action,
    BattleProvider battleProvider,
  ) async {
    HapticFeedback.heavyImpact();
    if (action == BattleAction.special) {
      _triggerBurst('SPECIAL!');
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _player.lunge.forward(from: 0);
    await battleProvider.executePlayerAction(action);
    if (!mounted) return;
    if (battleProvider.currentBattle?.battleEnded ?? false) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BattleResultScreen(
            battleResult: battleProvider.currentBattle!.toBattleResult(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: _kBg,
        body: _ScreenShaker(
          shakeAnim: _screenShakeAnim,
          child: Stack(
            children: [
              CustomPaint(painter: const _GridPainter(), size: size),

              if (_slashParticles.isNotEmpty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SlashPainter(List.from(_slashParticles)),
                      size: size,
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
                          _kPurple.op(0.04),
                          _kPurple.op(0.07),
                          _kPurple.op(0.04),
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
                      top: -100,
                      right: -80,
                      child: _Orb(
                        size: 300 * _orbIntensity.clamp(1.0, 1.8),
                        color: _orbIntensity > 1.5 ? _kRed : _kPurple,
                        opacity:
                            0.15 *
                            _pulseAnim.value *
                            (_orbIntensity > 1 ? _orbIntensity * 0.6 : 1),
                      ),
                    ),
                    Positioned(
                      bottom: -120,
                      left: -80,
                      child: _Orb(
                        size: 320,
                        color: _kGreen,
                        opacity: 0.10 * _pulseAnim.value,
                      ),
                    ),
                  ],
                ),
              ),

              if (_orbIntensity > 1.5)
                AnimatedBuilder(
                  animation: _vignetteAnim,
                  builder: (_, __) => Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.2,
                            colors: [
                              Colors.transparent,
                              _kRed.op(0.22 * _vignetteAnim.value),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 0,
                left: 0,
                child: CustomPaint(
                  painter: const _DiagonalAccentPainter(),
                  size: const Size(200, 200),
                ),
              ),

              if (!_introComplete)
                _IntroOverlay(
                  enemyName: widget.enemyCharacter.name,
                  enemyImageUrl: widget.enemyCharacter.imageUrl,
                  playerName: widget.playerCharacter?.name ?? 'You',
                  playerImageUrl: widget.playerCharacter?.imageUrl,
                  enemySlide: _enemyIntroSlide,
                  playerSlide: _playerIntroSlide,
                  fightAnim: _fightTextAnim,
                ),

              if (_introComplete)
                SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: _fadeOpacity,
                    child: SlideTransition(
                      position: _fadeSlide,
                      child: Consumer<BattleProvider>(
                        builder: (context, bp, _) {
                          if (bp.currentBattle == null) {
                            return Center(
                              child: AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (_, __) => CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: _kPurple.op(_pulseAnim.value),
                                ),
                              ),
                            );
                          }
                          final battle = bp.currentBattle!;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _checkHpChanges(battle);
                          });
                          return Column(
                            children: [
                              _TopBar(
                                roundNumber: _roundNumber,
                                isPlayerTurn: battle.isPlayerTurn,
                                blinkAnim: _blinkAnim,
                              ),
                              const SizedBox(height: 12),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _showTurnBanner
                                    ? AnimatedBuilder(
                                        animation: _turnBannerCtrl,
                                        builder: (_, __) => SlideTransition(
                                          position: _turnBannerSlide,
                                          child: FadeTransition(
                                            opacity: _turnBannerOpacity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                              child: _TurnBanner(
                                                text: _turnBannerText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              if (_showTurnBanner) const SizedBox(height: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    24,
                                  ),
                                  child: Column(
                                    children: [
                                      _CinematicArena(
                                        battle: battle,
                                        breatheScale: _breatheScale,
                                        breatheBob: _breatheBob,
                                        pulseAnim: _pulseAnim,
                                        enemy: _enemy,
                                        player: _player,
                                        heartbeatAnim: _heartbeatAnim,
                                        floatingNumbers: _floatingNumbers,
                                        enemyHpFlash: _enemyHpFlash,
                                        playerHpFlash: _playerHpFlash,
                                        orbIntensity: _orbIntensity,
                                      ),
                                      const SizedBox(height: 16),
                                      _BattleLogCard(battle: battle),
                                      const SizedBox(height: 16),
                                      if (!battle.battleEnded)
                                        _ActionPanel(
                                          isPlayerTurn: battle.isPlayerTurn,
                                          isProcessing: bp.isProcessing,
                                          pulseAnim: _pulseAnim,
                                          onAttack: () => _handleAction(
                                            BattleAction.attack,
                                            bp,
                                          ),
                                          onSpecial: () => _handleAction(
                                            BattleAction.special,
                                            bp,
                                          ),
                                          onHeal: () => _handleAction(
                                            BattleAction.heal,
                                            bp,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

              if (_showRound)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _roundAnim,
                        builder: (_, __) => Transform.scale(
                          scale: _roundAnim.value,
                          child: Opacity(
                            opacity: _roundAnim.value.clamp(0.0, 1.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: _kBg.op(0.92),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _kPurple.op(0.5),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kPurple.op(0.3),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                'ROUND $_roundNumber',
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_showCritical)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _burstAnim,
                      builder: (_, __) {
                        final isCrit = _criticalText.contains('CRITICAL');
                        final isHeal = _criticalText.contains('HEALED');
                        final burstColor = isHeal
                            ? _kGreen
                            : isCrit
                            ? _kGold
                            : _kPurple;
                        return Stack(
                          children: [
                            Opacity(
                              opacity: (1.0 - _burstAnim.value).clamp(
                                0.0,
                                0.35,
                              ),
                              child: Container(color: burstColor.op(0.18)),
                            ),
                            Center(
                              child: Transform.scale(
                                scale: 0.5 + _burstAnim.value * 1.5,
                                child: Opacity(
                                  opacity: (1.0 - _burstAnim.value).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  child: Text(
                                    _criticalText,
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 4,
                                      color: burstColor,
                                      shadows: [
                                        Shadow(
                                          color: burstColor.op(0.8),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
        colors: [color.op(opacity.clamp(0.0, 1.0)), Colors.transparent],
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  final int roundNumber;
  final bool isPlayerTurn;
  final Animation<double> blinkAnim;
  const _TopBar({
    required this.roundNumber,
    required this.isPlayerTurn,
    required this.blinkAnim,
  });
  @override
  Widget build(BuildContext context) {
    final turnColor = isPlayerTurn ? _kGreen : _kRed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _kRed.withOpacity(0.12),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: _kRed.withOpacity(0.3), width: 0.5),
            ),
            child: const Text(
              'BATTLE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: _kRed,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'ROUND $roundNumber',
            style: const TextStyle(
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
                    color: turnColor.withOpacity(blinkAnim.value),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isPlayerTurn ? 'YOUR TURN' : 'ENEMY TURN',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: turnColor.withOpacity(blinkAnim.value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  final String text;
  const _TurnBanner({required this.text});
  @override
  Widget build(BuildContext context) {
    final isPlayer = text.contains('YOUR');
    final color = isPlayer ? _kGreen : _kRed;
    final icon = isPlayer ? Icons.shield_rounded : Icons.electric_bolt_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
        boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 16)],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.4), width: 0.5),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: color,
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.3 + i * 0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CinematicArena extends StatelessWidget {
  final BattleState battle;
  final Animation<double> breatheScale, breatheBob, pulseAnim, heartbeatAnim;
  final _FighterAnims enemy, player;
  final List<_FloatingNumber> floatingNumbers;
  final double enemyHpFlash, playerHpFlash, orbIntensity;

  const _CinematicArena({
    required this.battle,
    required this.breatheScale,
    required this.breatheBob,
    required this.pulseAnim,
    required this.enemy,
    required this.player,
    required this.heartbeatAnim,
    required this.floatingNumbers,
    required this.enemyHpFlash,
    required this.playerHpFlash,
    required this.orbIntensity,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 40;
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: const _ArenaSplitPainter()),
          ),
          Row(
            children: [
              Expanded(
                child: _buildFighter(
                  anims: player,
                  isEnemy: false,
                  w: w,
                  hp: battle.playerHp,
                  maxHp: battle.playerMaxHp,
                  name: battle.playerCharacter.name,
                  imageUrl: battle.playerCharacter.imageUrl,
                  hpFlash: playerHpFlash,
                ),
              ),
              Expanded(
                child: _buildFighter(
                  anims: enemy,
                  isEnemy: true,
                  w: w,
                  hp: battle.enemyHp,
                  maxHp: battle.enemyMaxHp,
                  name: battle.enemyCharacter.name,
                  imageUrl: battle.enemyCharacter.imageUrl,
                  hpFlash: enemyHpFlash,
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, __) => Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kBg,
                    border: Border.all(
                      color: _kPurple.op(0.3 + 0.4 * pulseAnim.value),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.op(0.2 * pulseAnim.value),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: _kPurple.op(0.6 + 0.4 * pulseAnim.value),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...floatingNumbers.map((n) => _FloatingNumberWidget(number: n)),
        ],
      ),
    );
  }

  Widget _buildFighter({
    required _FighterAnims anims,
    required bool isEnemy,
    required double w,
    required int hp,
    required int maxHp,
    required String name,
    required String? imageUrl,
    required double hpFlash,
  }) {
    final isLowHp = hp / maxHp < 0.3;
    return AnimatedBuilder(
      animation: Listenable.merge([
        anims.shakeAnim,
        anims.flashAnim,
        breatheScale,
        breatheBob,
        anims.lungeAnim,
        pulseAnim,
      ]),
      builder: (_, __) {
        final lungeX = anims.lungeAnim.value * (w * 0.5) * (isEnemy ? -1 : 1);
        return Transform.translate(
          offset: Offset(anims.shakeAnim.value + lungeX, breatheBob.value),
          child: Transform.scale(
            scale: breatheScale.value,
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                _FighterPanel(
                  name: name,
                  imageUrl: imageUrl,
                  hp: hp,
                  maxHp: maxHp,
                  color: isEnemy ? _kRed : _kGreen,
                  label: isEnemy ? 'ENEMY' : 'YOU',
                  isPlayer: !isEnemy,
                  pulseAnim: pulseAnim,
                  heartbeatAnim: heartbeatAnim,
                  hpFlash: hpFlash,
                  isLowHp: isLowHp,
                ),
                if (anims.flashAnim.value > 0)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(
                        (0.5 * (1 - anims.flashAnim.value)).clamp(0.0, 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FighterPanel extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final int hp, maxHp;
  final Color color;
  final String label;
  final bool isPlayer, isLowHp;
  final Animation<double> pulseAnim, heartbeatAnim;
  final double hpFlash;

  const _FighterPanel({
    required this.name,
    required this.imageUrl,
    required this.hp,
    required this.maxHp,
    required this.color,
    required this.label,
    required this.isPlayer,
    required this.pulseAnim,
    required this.heartbeatAnim,
    required this.hpFlash,
    required this.isLowHp,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (hp / maxHp).clamp(0.0, 1.0);
    final hpColor = pct > 0.5
        ? color
        : pct > 0.25
        ? const Color(0xFFE8A838)
        : _kRed;
    return AnimatedBuilder(
      animation: Listenable.merge([heartbeatAnim, pulseAnim]),
      builder: (_, __) {
        final borderColor = isLowHp
            ? Color.lerp(
                color.withOpacity(0.2),
                _kRed.withOpacity(0.7),
                heartbeatAnim.value,
              )!
            : color.withOpacity(0.18);
        return Container(
          height: 240,
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            border: Border.all(color: borderColor, width: isLowHp ? 1.0 : 0.5),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withOpacity(0.13 + 0.06 * pulseAnim.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    if (imageUrl != null)
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            errorBuilder: (_, __, ___) => _CharacterSilhouette(
                              color: color,
                              isPlayer: isPlayer,
                            ),
                          ),
                        ),
                      )
                    else
                      _CharacterSilhouette(color: color, isPlayer: isPlayer),

                    Positioned(
                      top: 8,
                      left: isPlayer ? 8 : null,
                      right: isPlayer ? null : 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  border: Border(
                    top: BorderSide(color: color.withOpacity(0.2), width: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          widthFactor: pct,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Color.lerp(
                                hpColor,
                                Colors.white,
                                hpFlash * 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (hpFlash > 0.1 ? Colors.white : hpColor)
                                          .withOpacity(
                                            ((0.5 + 0.4 * pulseAnim.value) *
                                                    (1 + hpFlash))
                                                .clamp(0.0, 1.0),
                                          ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HP',
                          style: TextStyle(
                            fontSize: 7,
                            letterSpacing: 1,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        Text(
                          '$hp/$maxHp',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: hpColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CharacterSilhouette extends StatelessWidget {
  final Color color;
  final bool isPlayer;
  const _CharacterSilhouette({required this.color, required this.isPlayer});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    height: 114,
    child: CustomPaint(
      painter: _SilhouettePainter(color: color, isPlayer: isPlayer),
    ),
  );
}

class _FloatingNumberWidget extends StatefulWidget {
  final _FloatingNumber number;
  const _FloatingNumberWidget({required this.number});
  @override
  State<_FloatingNumberWidget> createState() => _FloatingNumberWidgetState();
}

class _FloatingNumberWidgetState extends State<_FloatingNumberWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  late final Animation<double> _opacity = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 5),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 4),
  ]).animate(_ctrl);
  late final Animation<double> _offsetY = Tween(
    begin: 0.0,
    end: -55.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.3), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 2),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 6),
  ]).animate(_ctrl);
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnemy = widget.number.isEnemy;
    return Positioned(
      top: isEnemy ? null : 20,
      bottom: isEnemy ? 20 : null,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, isEnemy ? _offsetY.value : -_offsetY.value),
          child: Transform.scale(
            scale: _scale.value,
            child: Opacity(
              opacity: _opacity.value,
              child: Center(
                child: Text(
                  widget.number.text,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: widget.number.text.contains('!!!') ? 20 : 16,
                    fontWeight: FontWeight.w900,
                    color: widget.number.color,
                    shadows: [
                      Shadow(
                        color: widget.number.color.withOpacity(0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BattleLogCard extends StatelessWidget {
  final BattleState battle;
  const _BattleLogCard({required this.battle});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Container(width: 3, height: 14, color: _kPurple),
                const SizedBox(width: 8),
                Text(
                  'BATTLE LOG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _kPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${battle.moves.length}',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: _kPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: battle.moves.isEmpty
                ? Center(
                    child: Text(
                      'AWAITING FIRST MOVE...',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    itemCount: battle.moves.length,
                    itemBuilder: (context, i) {
                      final move = battle.moves[battle.moves.length - 1 - i];
                      final isLatest = i == 0;
                      final isPlayer =
                          move.description.toLowerCase().contains('you') ||
                          move.description.toLowerCase().contains('player');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.only(top: 5, right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLatest
                                    ? (isPlayer ? _kGreen : _kRed)
                                    : Colors.white.withOpacity(0.15),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                move.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.5,
                                  color: Colors.white.withOpacity(
                                    isLatest ? 0.8 : 0.3,
                                  ),
                                  fontWeight: isLatest
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final bool isPlayerTurn, isProcessing;
  final Animation<double> pulseAnim;
  final VoidCallback onAttack, onSpecial, onHeal;
  const _ActionPanel({
    required this.isPlayerTurn,
    required this.isProcessing,
    required this.pulseAnim,
    required this.onAttack,
    required this.onSpecial,
    required this.onHeal,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPlayerTurn && !isProcessing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
        ),
        child: AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Column(
            children: [
              Text(
                'ENEMY IS THINKING',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  letterSpacing: 2,
                  color: _kRed.withOpacity(pulseAnim.value),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kRed.withOpacity(
                        (pulseAnim.value - i * 0.15).clamp(0.0, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 14, color: _kGreen),
            const SizedBox(width: 8),
            Text(
              'CHOOSE ACTION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 0.5,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'ATTACK',
                sublabel: 'STRIKE',
                icon: Icons.flash_on_rounded,
                color: _kRed,
                enabled: isPlayerTurn && !isProcessing,
                onTap: onAttack,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                label: 'SPECIAL',
                sublabel: 'POWER',
                icon: Icons.bolt_rounded,
                color: _kPurple,
                enabled: isPlayerTurn && !isProcessing,
                onTap: onSpecial,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                label: 'HEAL',
                sublabel: 'RESTORE',
                icon: Icons.favorite_rounded,
                color: _kGreen,
                enabled: isPlayerTurn && !isProcessing,
                onTap: onHeal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label, sublabel;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    return GestureDetector(
      onTapDown: active ? (_) => setState(() => _pressed = true) : null,
      onTapUp: active
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: active ? () => setState(() => _pressed = false) : null,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: active
                  ? (_pressed
                        ? widget.color.withOpacity(0.22)
                        : widget.color.withOpacity(0.10))
                  : Colors.white.withOpacity(0.02),
              border: Border.all(
                color: active
                    ? (_pressed
                          ? widget.color.withOpacity(0.5)
                          : widget.color.withOpacity(0.2))
                    : Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
              boxShadow: active && _pressed
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Icon(
                  widget.icon,
                  size: 22,
                  color: active ? widget.color : Colors.white.withOpacity(0.15),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: active
                        ? widget.color
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.sublabel,
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: active
                        ? widget.color.withOpacity(0.5)
                        : Colors.white.withOpacity(0.12),
                  ),
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
              height: active ? (_pressed ? 2.0 : 1.5) : 0.5,
              decoration: BoxDecoration(
                color: active
                    ? widget.color.withOpacity(_pressed ? 1.0 : 0.7)
                    : Colors.white.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroOverlay extends StatelessWidget {
  final String enemyName, playerName;
  final String? enemyImageUrl;
  final String? playerImageUrl;
  final Animation<Offset> enemySlide, playerSlide;
  final Animation<double> fightAnim;

  const _IntroOverlay({
    required this.enemyName,
    required this.enemyImageUrl,
    required this.playerName,
    required this.playerImageUrl,
    required this.enemySlide,
    required this.playerSlide,
    required this.fightAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: _kBg,
        child: Stack(
          children: [
            CustomPaint(
              painter: const _GridPainter(),
              size: MediaQuery.of(context).size,
            ),
            Column(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: enemySlide,
                    child: _IntroFighterHalf(
                      name: enemyName,
                      imageUrl: enemyImageUrl,
                      label: 'ENEMY',
                      color: _kRed,
                      isEnemy: true,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: fightAnim,
                  builder: (_, __) => Transform.scale(
                    scale: fightAnim.value,
                    child: Opacity(
                      opacity: fightAnim.value.clamp(0.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'FIGHT!',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                            color: _kPurple,
                            shadows: [
                              Shadow(
                                color: _kPurple.withOpacity(0.8),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SlideTransition(
                    position: playerSlide,
                    child: _IntroFighterHalf(
                      name: playerName,
                      imageUrl: playerImageUrl,
                      label: 'YOU',
                      color: _kGreen,
                      isEnemy: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroFighterHalf extends StatelessWidget {
  final String name, label;
  final String? imageUrl;
  final Color color;
  final bool isEnemy;
  const _IntroFighterHalf({
    required this.name,
    required this.imageUrl,
    required this.label,
    required this.color,
    required this.isEnemy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: isEnemy
              ? BorderSide.none
              : BorderSide(color: color.withOpacity(0.3), width: 0.5),
          bottom: isEnemy
              ? BorderSide(color: color.withOpacity(0.3), width: 0.5)
              : BorderSide.none,
        ),
        gradient: LinearGradient(
          begin: isEnemy ? Alignment.topCenter : Alignment.bottomCenter,
          end: isEnemy ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [color.withOpacity(0.08), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.4), width: 1),
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.person_rounded, size: 40, color: color),
                    ),
                  )
                : Icon(
                    isEnemy
                        ? Icons.person_rounded
                        : Icons.sports_martial_arts_rounded,
                    size: isEnemy ? 40 : 44,
                    color: color,
                  ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: color.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class BattleHistoryScreen extends StatefulWidget {
  const BattleHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BattleHistoryScreen> createState() => _BattleHistoryScreenState();
}

class _BattleHistoryScreenState extends State<BattleHistoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
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

  late final Animation<double> _fadeOpacity = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
  late final Animation<Offset> _fadeSlide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
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

  bool _isLoading = true;
  List<Map<String, dynamic>> _battles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await userProvider.loadBattleHistory(authProvider.currentUser!.uid);
      if (mounted) {
        setState(() {
          _battles = userProvider.battleHistory;
          _isLoading = false;
        });
        _fadeCtrl.forward();
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeCtrl.forward();
      }
    }
  }

  void _goBack() {
    HapticFeedback.lightImpact();
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed('/');
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      DateTime dt;
      if (timestamp is Timestamp) {
        dt = timestamp.toDate();
      } else if (timestamp is String) {
        dt = DateTime.parse(timestamp);
      } else {
        return '—';
      }
      return DateFormat('MMM dd, yyyy · HH:mm').format(dt);
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0E1A),
        body: Stack(
          children: [
            CustomPaint(painter: _GridPainter(), size: size),

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
                        const Color(0xFF7F77DD).withOpacity(0.04),
                        const Color(0xFF7F77DD).withOpacity(0.07),
                        const Color(0xFF7F77DD).withOpacity(0.04),
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
              child: _Orb(
                size: 300,
                color: const Color(0xFF7F77DD),
                opacity: 0.12,
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _Orb(
                size: 320,
                color: const Color(0xFF1D9E75),
                opacity: 0.08,
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              child: CustomPaint(
                painter: _DiagonalAccentPainter(),
                size: const Size(200, 200),
              ),
            ),

            SafeArea(
              bottom: false,
              child: _isLoading
                  ? _buildLoading()
                  : FadeTransition(
                      opacity: _fadeOpacity,
                      child: SlideTransition(
                        position: _fadeSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: _buildTopBar(),
                            ),

                            const SizedBox(height: 16),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _buildSummaryRow(),
                            ),

                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const _SectionLabel(label: 'BATTLE LOG'),
                            ),

                            const SizedBox(height: 10),

                            Expanded(
                              child: _battles.isEmpty
                                  ? _buildEmpty()
                                  : ListView.separated(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: bottomPadding + 24,
                                      ),
                                      itemCount: _battles.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (_, i) => _BattleCard(
                                        battle: _battles[i],
                                        index: i,
                                        pulseAnim: _pulseAnim,
                                        formatDate: _formatDate,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: _goBack,
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
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7F77DD).withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color(0xFF7F77DD).withOpacity(0.35),
              width: 0.5,
            ),
          ),
          child: const Text(
            'ARCHIVE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: Color(0xFF7F77DD),
            ),
          ),
        ),

        const SizedBox(width: 10),

        const Text(
          'BATTLE HISTORY',
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
          animation: _blinkAnim,
          builder: (_, __) => Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1D9E75).withOpacity(_blinkAnim.value),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${_battles.length} RECORDS',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D9E75).withOpacity(_blinkAnim.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final wins = _battles.where((b) => b['playerWon'] == true).length;
    final losses = _battles.length - wins;
    final winRate = _battles.isEmpty ? 0.0 : (wins / _battles.length) * 100;

    return Row(
      children: [
        _MiniStat(
          value: '${_battles.length}',
          label: 'TOTAL',
          color: const Color(0xFF7F77DD),
        ),
        const SizedBox(width: 8),
        _MiniStat(
          value: '$wins',
          label: 'WINS',
          color: const Color(0xFF1D9E75),
        ),
        const SizedBox(width: 8),
        _MiniStat(
          value: '$losses',
          label: 'LOSSES',
          color: const Color(0xFFE24B4A),
        ),
        const SizedBox(width: 8),
        _MiniStat(
          value: '${winRate.toStringAsFixed(1)}%',
          label: 'RATE',
          color: const Color(0xFFE8A838),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: const Color(0xFF7F77DD).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LOADING RECORDS...',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 40,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: 16),
          Text(
            'NO BATTLES YET',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a battle to see your record here.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.2),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BattleCard extends StatelessWidget {
  final Map<String, dynamic> battle;
  final int index;
  final Animation<double> pulseAnim;
  final String Function(dynamic) formatDate;

  const _BattleCard({
    required this.battle,
    required this.index,
    required this.pulseAnim,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWin = battle['playerWon'] ?? false;
    final Color outcomeColor = isWin
        ? const Color(0xFF1D9E75)
        : const Color(0xFFE24B4A);
    final String enemyName = (battle['enemyCharacterName'] ?? 'Unknown')
        .toString()
        .toUpperCase();
    final dynamic hp = battle['playerFinalHp'] ?? 0;
    final dynamic moves = battle['totalMoves'] ?? 0;
    final String date = formatDate(battle['timestamp'] ?? battle['createdAt']);

    final Color hpColor = hp is int && hp > 50
        ? const Color(0xFF1D9E75)
        : hp is int && hp > 25
        ? const Color(0xFFE8A838)
        : const Color(0xFFE24B4A);

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isWin
                ? outcomeColor.withOpacity(0.15)
                : Colors.white.withOpacity(0.06),
            width: 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 52,
                decoration: BoxDecoration(
                  color: outcomeColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: outcomeColor.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isWin ? Icons.emoji_events_rounded : Icons.shield_rounded,
                      size: 18,
                      color: outcomeColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWin ? 'WIN' : 'LOSS',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: outcomeColor,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'vs $enemyName',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white.withOpacity(0.25),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          _InlineStatChip(
                            icon: Icons.favorite_rounded,
                            value: '$hp HP',
                            color: hpColor,
                          ),
                          const SizedBox(width: 8),
                          _InlineStatChip(
                            icon: Icons.bolt_rounded,
                            value: '$moves moves',
                            color: const Color(0xFF7F77DD),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '#${(index + 1).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.08),
                    letterSpacing: 1,
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

class _InlineStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InlineStatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: color.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF7F77DD),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 0.5, color: Colors.white.withOpacity(0.06)),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _DiagonalAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF7F77DD).withOpacity(0.07)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 6; i++) {
      final o = i * 18.0;
      canvas.drawLine(Offset(o, 0), Offset(0, o), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
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

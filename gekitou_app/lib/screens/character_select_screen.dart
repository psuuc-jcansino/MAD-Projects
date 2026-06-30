import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/character_model.dart';
import '../providers/character_provider.dart';
import 'battle_screen.dart';

extension _SafeOpacity on Color {
  Color op(double v) => withOpacity(v.clamp(0.0, 1.0));
}

const _kBg = Color(0xFF0A0C18);
const _kSurface = Color(0xFF111425);
const _kPurple = Color(0xFF7F77DD);
const _kGreen = Color(0xFF1D9E75);
const _kRed = Color(0xFFE24B4A);
const _kGold = Color(0xFFFFD700);

enum _SelectStep { pickPlayer, pickEnemy }

class CharacterSelectScreen extends StatefulWidget {
  final String difficulty;
  const CharacterSelectScreen({Key? key, required this.difficulty})
    : super(key: key);

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..forward();

  late final AnimationController _scanCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat();

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final AnimationController _previewCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final AnimationController _fightCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final AnimationController _stepCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final Animation<double> _fadeOpacity = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

  late final Animation<Offset> _fadeSlide = Tween<Offset>(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));

  late final Animation<double> _scanAnim = Tween<double>(
    begin: -0.12,
    end: 1.12,
  ).animate(CurvedAnimation(parent: _scanCtrl, curve: Curves.linear));

  late final Animation<double> _pulseAnim = Tween<double>(
    begin: 0.4,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  late final Animation<double> _fightScale = Tween<double>(
    begin: 0.82,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _fightCtrl, curve: Curves.elasticOut));

  late final Animation<Offset> _stepSlide = Tween<Offset>(
    begin: const Offset(0.1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));

  late final Animation<double> _stepFade = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));

  PageController _pageCtrl = PageController(viewportFraction: 0.88);

  _SelectStep _step = _SelectStep.pickPlayer;
  Character? _selectedPlayer;
  Character? _selectedEnemy;
  int _currentPage = 0;

  Color get _difficultyColor {
    switch (widget.difficulty) {
      case 'easy':
        return _kGreen;
      case 'hard':
        return _kRed;
      default:
        return _kPurple;
    }
  }

  String get _difficultyLabel {
    switch (widget.difficulty) {
      case 'easy':
        return 'RELAXED';
      case 'hard':
        return 'BRUTAL';
      default:
        return 'BALANCED';
    }
  }

  Color get _stepColor =>
      _step == _SelectStep.pickPlayer ? _kGold : _difficultyColor;

  String get _sectionLabel => _step == _SelectStep.pickPlayer
      ? 'CHOOSE YOUR HERO'
      : 'CHOOSE YOUR ENEMY';

  void _resetPageController() {
    _pageCtrl.dispose();
    _pageCtrl = PageController(viewportFraction: 0.88);
  }

  void _onSelect(Character character) {
    HapticFeedback.selectionClick();
    if (_step == _SelectStep.pickPlayer) {
      _resetPageController();
      setState(() {
        _selectedPlayer = character;
        _step = _SelectStep.pickEnemy;
        _currentPage = 0;
        _selectedEnemy = null;
      });
      _previewCtrl.forward(from: 0);
      _stepCtrl.forward(from: 0);
    } else {
      final first = _selectedEnemy == null;
      setState(() => _selectedEnemy = character);
      if (first) {
        _fightCtrl.forward(from: 0);
      } else {
        _previewCtrl.forward(from: 0.4);
      }
    }
  }

  void _goBack() {
    HapticFeedback.lightImpact();
    _resetPageController();
    setState(() {
      _step = _SelectStep.pickPlayer;
      _selectedEnemy = null;
      _currentPage = 0;
    });
    _fightCtrl.reverse();
    _stepCtrl.forward(from: 0);
  }

  void _startBattle() {
    if (_selectedPlayer == null || _selectedEnemy == null) return;
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BattleScreen(
          playerCharacter: _selectedPlayer!,
          enemyCharacter: _selectedEnemy!,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<CharacterProvider>(context, listen: false).fetchCharacters();
    });
    _stepCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    _previewCtrl.dispose();
    _fightCtrl.dispose();
    _stepCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) => Positioned(
              top: size.height * _scanAnim.value - 40,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _stepColor.op(0.03),
                        _stepColor.op(0.06),
                        _stepColor.op(0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    top: -110,
                    right: -90,
                    child: _Orb(
                      size: 320,
                      color: _stepColor,
                      opacity: _pulseAnim.value * 0.10,
                    ),
                  ),
                  Positioned(
                    bottom: -130,
                    left: -90,
                    child: _Orb(size: 340, color: _kPurple, opacity: 0.08),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DiagonalAccentPainter(color: _stepColor),
                size: const Size(180, 180),
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
                    _TopBar(
                      difficulty: widget.difficulty,
                      difficultyColor: _difficultyColor,
                      difficultyLabel: _difficultyLabel,
                      step: _step,
                      onBack: _step == _SelectStep.pickEnemy
                          ? _goBack
                          : () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(height: 10),

                    _StepIndicator(
                      step: _step,
                      playerColor: _kGold,
                      enemyColor: _difficultyColor,
                    ),

                    const SizedBox(height: 10),

                    ClipRect(
                      child: SizedBox(
                        height: 128,
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => _VSPreviewStrip(
                            player: _selectedPlayer,
                            enemy: _selectedEnemy,
                            pulseValue: _pulseAnim.value,
                            difficultyColor: _difficultyColor,
                            onFight: _startBattle,
                            fightScale: _fightScale,
                          ),
                        ),
                      ),
                    ),

                    SlideTransition(
                      position: _stepSlide,
                      child: FadeTransition(
                        opacity: _stepFade,
                        child: _SectionLabel(
                          label: _sectionLabel,
                          color: _stepColor,
                          showSelectedBadge:
                              _step == _SelectStep.pickEnemy &&
                              _selectedEnemy != null,
                          badgeColor: _difficultyColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Consumer<CharacterProvider>(
                        builder: (context, cp, _) {
                          if (cp.isLoading) {
                            return _LoadingState(
                              pulseAnim: _pulseAnim,
                              color: _stepColor,
                            );
                          }
                          final all = cp.allCharacters;
                          if (all.isEmpty) return const _EmptyState();

                          final list = _step == _SelectStep.pickEnemy
                              ? all
                                    .where((c) => c.id != _selectedPlayer?.id)
                                    .toList()
                              : all;

                          return _CharacterCarousel(
                            key: ValueKey(_pageCtrl.hashCode),
                            characters: list,
                            currentPage: _currentPage,
                            accentColor: _stepColor,
                            selectedId: _step == _SelectStep.pickPlayer
                                ? _selectedPlayer?.id
                                : _selectedEnemy?.id,
                            pageCtrl: _pageCtrl,
                            onPageChanged: (i) =>
                                setState(() => _currentPage = i),
                            onSelect: _onSelect,
                          );
                        },
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
  }
}

class _CharacterCarousel extends StatelessWidget {
  final List<Character> characters;
  final int currentPage;
  final Color accentColor;
  final String? selectedId;
  final PageController pageCtrl;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<Character> onSelect;

  const _CharacterCarousel({
    Key? key,
    required this.characters,
    required this.currentPage,
    required this.accentColor,
    required this.selectedId,
    required this.pageCtrl,
    required this.onPageChanged,
    required this.onSelect,
  }) : super(key: key);

  void _animateTo(int page) {
    pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoLeft = currentPage > 0;
    final canGoRight = currentPage < characters.length - 1;

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: pageCtrl,
                physics: const ClampingScrollPhysics(),
                itemCount: characters.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, i) {
                  final char = characters[i];
                  final isSelected = char.id == selectedId;
                  return _CarouselCard(
                    character: char,
                    isSelected: isSelected,
                    accentColor: accentColor,
                    onSelect: () => onSelect(char),
                  );
                },
              ),
              Positioned(
                left: 0,
                child: _CarouselArrow(
                  icon: Icons.chevron_left_rounded,
                  visible: canGoLeft,
                  accentColor: accentColor,
                  onTap: () => _animateTo(currentPage - 1),
                ),
              ),
              Positioned(
                right: 0,
                child: _CarouselArrow(
                  icon: Icons.chevron_right_rounded,
                  visible: canGoRight,
                  accentColor: accentColor,
                  onTap: () => _animateTo(currentPage + 1),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SWIPE',
                style: TextStyle(
                  fontSize: 7,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
              const SizedBox(width: 8),
              _SlidingDotIndicator(
                count: characters.length,
                currentPage: currentPage,
                accentColor: accentColor,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.swipe_rounded,
                size: 10,
                color: Colors.white.withOpacity(0.18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CarouselArrow extends StatefulWidget {
  final IconData icon;
  final bool visible;
  final Color accentColor;
  final VoidCallback onTap;

  const _CarouselArrow({
    required this.icon,
    required this.visible,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_CarouselArrow> createState() => _CarouselArrowState();
}

class _CarouselArrowState extends State<_CarouselArrow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: widget.visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 32,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _pressed
                  ? widget.accentColor.withOpacity(0.14)
                  : Colors.white.withOpacity(0.04),
              border: Border.all(
                color: _pressed
                    ? widget.accentColor.withOpacity(0.40)
                    : Colors.white.withOpacity(0.08),
                width: 0.5,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _pressed
                  ? widget.accentColor
                  : Colors.white.withOpacity(0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselCard extends StatefulWidget {
  final Character character;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onSelect;

  const _CarouselCard({
    required this.character,
    required this.isSelected,
    required this.accentColor,
    required this.onSelect,
  });

  @override
  State<_CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<_CarouselCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardH = constraints.maxHeight;
          final avatarSize = (cardH * 0.42).clamp(80.0, 220.0);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: cardH,
            decoration: BoxDecoration(
              color: widget.isSelected ? c.op(0.09) : _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected ? c.op(0.50) : Colors.white.op(0.07),
                width: widget.isSelected ? 1.0 : 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: widget.isSelected ? 2 : 0.5,
                      color: widget.isSelected
                          ? c.op(0.85)
                          : Colors.white.op(0.06),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: c.op(0.10),
                              border: Border.all(
                                color: c.op(widget.isSelected ? 0.40 : 0.18),
                                width: 0.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: widget.character.imageUrl != null
                                  ? Image.network(
                                      widget.character.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _AvatarFallback(
                                            color: c,
                                            name: widget.character.name,
                                          ),
                                    )
                                  : _AvatarFallback(
                                      color: c,
                                      name: widget.character.name,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          widget.character.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.white.op(0.82),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatPill(
                              label: 'HP',
                              value: '${widget.character.hp}',
                              color: _kGreen,
                            ),
                            const SizedBox(width: 8),
                            _StatPill(
                              label: 'ATK',
                              value: '${widget.character.attack}',
                              color: _kRed,
                            ),
                          ],
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTapDown: (_) => setState(() => _pressed = true),
                          onTapUp: (_) {
                            setState(() => _pressed = false);
                            widget.onSelect();
                          },
                          onTapCancel: () => setState(() => _pressed = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 110),
                            width: double.infinity,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: widget.isSelected
                                  ? c.op(_pressed ? 0.28 : 0.18)
                                  : c.op(_pressed ? 0.20 : 0.10),
                              border: Border.all(
                                color: widget.isSelected
                                    ? c.op(_pressed ? 0.70 : 0.50)
                                    : c.op(_pressed ? 0.45 : 0.22),
                                width: widget.isSelected ? 1.0 : 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.isSelected
                                      ? Icons.check_rounded
                                      : Icons.flash_on_rounded,
                                  size: 14,
                                  color: c,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.isSelected ? 'SELECTED' : 'SELECT',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 3,
                                    color: c,
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
          );
        },
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final Color color;
  final String name;
  const _AvatarFallback({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
    return Container(
      color: color.op(0.08),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: color.op(0.55),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool showSelectedBadge;
  final Color badgeColor;

  const _SectionLabel({
    required this.label,
    required this.color,
    required this.showSelectedBadge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(width: 3, height: 13, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: Colors.white.op(0.32),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 0.5, color: Colors.white.op(0.07))),
          if (showSelectedBadge) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.op(0.12),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '1 SELECTED',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final _SelectStep step;
  final Color playerColor, enemyColor;

  const _StepIndicator({
    required this.step,
    required this.playerColor,
    required this.enemyColor,
  });

  @override
  Widget build(BuildContext context) {
    final onPlayer = step == _SelectStep.pickPlayer;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StepPill(
            number: '1',
            label: 'YOUR HERO',
            color: playerColor,
            isActive: onPlayer,
            isDone: !onPlayer,
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 0.5,
              color: onPlayer ? Colors.white.op(0.08) : enemyColor.op(0.40),
            ),
          ),
          _StepPill(
            number: '2',
            label: 'ENEMY',
            color: enemyColor,
            isActive: !onPlayer,
            isDone: false,
          ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final String number, label;
  final Color color;
  final bool isActive, isDone;

  const _StepPill({
    required this.number,
    required this.label,
    required this.color,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final on = isActive || isDone;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: on ? color.op(0.11) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: on ? color.op(0.34) : Colors.white.op(0.09),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? color.op(0.22) : Colors.white.op(0.05),
            ),
            child: Center(
              child: isDone
                  ? Icon(Icons.check_rounded, size: 9, color: color)
                  : Text(
                      number,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: isActive ? color : Colors.white.op(0.22),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: on ? color : Colors.white.op(0.22),
            ),
          ),
        ],
      ),
    );
  }
}

class _VSPreviewStrip extends StatelessWidget {
  final Character? player;
  final Character? enemy;
  final double pulseValue;
  final Color difficultyColor;
  final VoidCallback onFight;
  final Animation<double> fightScale;

  const _VSPreviewStrip({
    required this.player,
    required this.enemy,
    required this.pulseValue,
    required this.difficultyColor,
    required this.onFight,
    required this.fightScale,
  });

  @override
  Widget build(BuildContext context) {
    final vsBorderOpacity = (0.22 + 0.45 * pulseValue).clamp(0.0, 1.0);
    final vsTextOpacity = (0.50 + 0.40 * pulseValue).clamp(0.0, 1.0);
    final hasBoth = player != null && enemy != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.op(0.025),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.op(0.07), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: player != null
                        ? _PreviewFighter(
                            name: player!.name,
                            imageUrl: player!.imageUrl,
                            label: 'YOU',
                            color: _kGold,
                            hp: player!.hp,
                            atk: player!.attack,
                            alignLeft: true,
                          )
                        : _EmptyFighterSlot(
                            label: 'PICK HERO',
                            color: _kGold,
                            alignLeft: true,
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kBg,
                        border: Border.all(
                          color: _kPurple.op(vsBorderOpacity),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'VS',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: _kPurple.op(vsTextOpacity),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: enemy != null
                        ? _PreviewFighter(
                            name: enemy!.name,
                            imageUrl: enemy!.imageUrl,
                            label: 'ENEMY',
                            color: difficultyColor,
                            hp: enemy!.hp,
                            atk: enemy!.attack,
                            alignLeft: false,
                          )
                        : _EmptyFighterSlot(
                            label: 'PICK ENEMY',
                            color: difficultyColor,
                            alignLeft: false,
                          ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: hasBoth ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !hasBoth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: ScaleTransition(
                  scale: fightScale,
                  child: _FightButton(color: difficultyColor, onTap: onFight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewFighter extends StatelessWidget {
  final String name, label;
  final String? imageUrl;
  final Color color;
  final int hp, atk;
  final bool alignLeft;

  const _PreviewFighter({
    required this.name,
    required this.imageUrl,
    required this.label,
    required this.color,
    required this.hp,
    required this.atk,
    required this.alignLeft,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color.op(0.11),
        border: Border.all(color: color.op(0.28), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person_rounded, size: 14, color: color.op(0.45)),
              )
            : Icon(
                alignLeft
                    ? Icons.sports_martial_arts_rounded
                    : Icons.person_rounded,
                size: 14,
                color: color.op(0.55),
              ),
      ),
    );

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.op(0.11),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.op(0.28), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: color,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: alignLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: alignLeft
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: alignLeft
              ? [avatar, const SizedBox(width: 6), badge]
              : [badge, const SizedBox(width: 6), avatar],
        ),
        const SizedBox(height: 4),
        Text(
          (name.length > 11 ? '${name.substring(0, 10)}…' : name).toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: alignLeft
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            _MiniStat(label: 'HP', value: '$hp', color: _kGreen),
            const SizedBox(width: 4),
            _MiniStat(label: 'ATK', value: '$atk', color: _kRed),
          ],
        ),
      ],
    );
  }
}

class _EmptyFighterSlot extends StatelessWidget {
  final String label;
  final Color color;
  final bool alignLeft;

  const _EmptyFighterSlot({
    required this.label,
    required this.color,
    required this.alignLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignLeft
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.op(0.03),
            border: Border.all(color: Colors.white.op(0.07), width: 0.5),
          ),
          child: Icon(
            Icons.question_mark_rounded,
            size: 12,
            color: Colors.white.op(0.16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 7,
            letterSpacing: 1.2,
            color: color.op(0.38),
          ),
        ),
      ],
    );
  }
}

class _FightButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  const _FightButton({required this.color, required this.onTap});

  @override
  State<_FightButton> createState() => _FightButtonState();
}

class _FightButtonState extends State<_FightButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        width: double.infinity,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: widget.color.op(_pressed ? 0.22 : 0.11),
          border: Border.all(
            color: widget.color.op(_pressed ? 0.55 : 0.24),
            width: _pressed ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on_rounded, size: 13, color: widget.color),
            const SizedBox(width: 7),
            Text(
              'FIGHT',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.op(0.09),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.op(0.18), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: color.op(0.65),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.op(0.09),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.op(0.20), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: color.op(0.65),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String difficulty, difficultyLabel;
  final Color difficultyColor;
  final _SelectStep step;
  final VoidCallback onBack;

  const _TopBar({
    required this.difficulty,
    required this.difficultyColor,
    required this.difficultyLabel,
    required this.step,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white.op(0.04),
                border: Border.all(color: Colors.white.op(0.08), width: 0.5),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 13,
                color: Colors.white.op(0.42),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step == _SelectStep.pickPlayer
                      ? 'SELECT YOUR HERO'
                      : 'SELECT OPPONENT',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: difficultyColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${difficulty.toUpperCase()} · $difficultyLabel',
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w600,
                        color: difficultyColor.op(0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: difficultyColor.op(0.11),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: difficultyColor.op(0.28), width: 0.5),
            ),
            child: Text(
              difficulty.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: difficultyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final Animation<double> pulseAnim;
  final Color color;
  const _LoadingState({required this.pulseAnim, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: color.op(pulseAnim.value.clamp(0.3, 1.0)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'LOADING CHARACTERS...',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 2,
                color: Colors.white.op(0.25),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 44,
            color: Colors.white.op(0.10),
          ),
          const SizedBox(height: 12),
          Text(
            'NO CHARACTERS FOUND',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              letterSpacing: 2,
              color: Colors.white.op(0.22),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidingDotIndicator extends StatelessWidget {
  final int count, currentPage;
  final Color accentColor;

  static const int _kMaxDots = 7;
  static const double _dotW = 8.0;
  static const double _activeDotW = 20.0;
  static const double _dotH = 8.0;
  static const double _dotGap = 4.0;
  static const double _padH = 8.0;
  static const double _padV = 10.0;

  const _SlidingDotIndicator({
    required this.count,
    required this.currentPage,
    required this.accentColor,
  });

  int get _windowStart {
    if (count <= _kMaxDots) return 0;
    final half = _kMaxDots ~/ 2;
    final start = currentPage - half;
    return start.clamp(0, count - _kMaxDots);
  }

  @override
  Widget build(BuildContext context) {
    final visible = count.clamp(0, _kMaxDots);
    final start = _windowStart;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _padV, vertical: _padH),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(visible, (slot) {
          final i = start + slot;
          final active = i == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: _dotGap),
            width: active ? _activeDotW : _dotW,
            height: _dotH,
            decoration: BoxDecoration(
              color: active ? accentColor : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(active ? 4 : 3),
            ),
          );
        }),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.020)
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
  final Color color;
  const _DiagonalAccentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(0.06)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 7; i++) {
      final o = i * 16.0;
      canvas.drawLine(Offset(o, 0), Offset(0, o), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _Orb extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const _Orb({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color.op(opacity), Colors.transparent]),
    ),
  );
}

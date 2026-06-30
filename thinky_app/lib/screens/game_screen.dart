import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thinky_app/constants/shape_type.dart';
import 'package:thinky_app/constants/color_type.dart';
import 'package:thinky_app/models/kid_profile.dart';

import '../constants/category.dart';
import '../constants/category_theme.dart';
import '../models/difficulty.dart';
import '../models/game_question.dart';
import '../screens/result_screen.dart';
import '../utils/letters_generator.dart';
import '../utils/numbers_generator.dart';
import '../utils/shapes_generator.dart';
import '../utils/colors_generator.dart';
import '../widgets/answer_option.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/shape_option_tile.dart';
import '../widgets/color_option_tile.dart';

class GameScreen extends StatefulWidget {
  final CategoryType category;
  final Difficulty difficulty;
  final KidProfile profile;

  const GameScreen({
    super.key,
    required this.category,
    required this.difficulty,
    required this.profile,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int totalQuestions = 10;

  late GameQuestion<dynamic> _question;
  int _currentQuestion = 1;
  int _score = 0;

  bool _showFeedback = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    switch (widget.category) {
      case CategoryType.numbers:
        _question = NumbersGenerator.generate(widget.difficulty);
        break;
      case CategoryType.letters:
        _question = LettersGenerator.generate(widget.difficulty);
        break;
      case CategoryType.shapes:
        _question = ShapesGenerator.generate(widget.difficulty);
        break;
      case CategoryType.colors:
        _question = ColorsGenerator.generate(widget.difficulty);
        break;
    }
  }

  void _onAnswerSelected(dynamic selected) {
    if (_showFeedback) return;

    final correct = selected == _question.correctAnswer;

    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
      if (correct) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion >= totalQuestions) {
      _endGame();
      return;
    }

    setState(() {
      _currentQuestion++;
      _showFeedback = false;
      _loadQuestion();
    });
  }

  void _endGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: _score,
          total: totalQuestions,
          category: widget.category,
          difficulty: _difficultyLabel(widget.difficulty),
          profile: widget.profile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = categoryThemes[widget.category]!;

    final bool isHardLetters =
        widget.category == CategoryType.letters &&
        widget.difficulty == Difficulty.hard;

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
          child: Stack(
            children: [
              _SoftDecor(accent: theme.accentColor),

              Column(
                children: [
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              _titleForCategory(widget.category),
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

                            const SizedBox(height: 4),
                            Text(
                              '${_difficultyLabel(widget.difficulty)} Difficulty',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedStarChip(score: _score),
                        _InfoChip(label: '$_currentQuestion / $totalQuestions'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            top: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.accentColor.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(36),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 18,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.accentColor.withOpacity(
                                        0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Text(
                                      'Choose the correct answer',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: theme.accentColor,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: theme.accentColor,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Column(
                                    children: [
                                      if (_question.imagePath != null) ...[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: Image.asset(
                                            _question.imagePath!,
                                            height: 130,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                      ],

                                      if (_question.promptText != null &&
                                          _question.promptTextColorValue !=
                                              null) ...[
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 14,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _question.promptText!,
                                              style: GoogleFonts.fredoka(
                                                fontSize: 34,
                                                fontWeight: FontWeight.w800,
                                                color: Color(
                                                  _question
                                                      .promptTextColorValue!,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],

                                      Text(
                                        _question.question,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 22),

                                if (widget.category == CategoryType.shapes)
                                  _gridShapes()
                                else if (widget.category == CategoryType.colors)
                                  _gridColors()
                                else
                                  _gridDefault(isHardLetters),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              if (_showFeedback)
                FeedbackOverlay(
                  isCorrect: _isCorrect,
                  onDismiss: _nextQuestion,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridShapes() => _grid(
    (o) => ShapeOptionTile(
      shape: o as ShapeType,
      onTap: () => _onAnswerSelected(o),
    ),
  );

  Widget _gridColors() {
    final hideVisuals = _question.hideColorOptionVisuals;
    final bool isHardColor =
        widget.category == CategoryType.colors &&
        widget.difficulty == Difficulty.hard;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isHardColor ? 2.2 : 1,
      ),
      itemCount: _question.options.length,
      itemBuilder: (context, i) {
        final o = _question.options[i];

        return hideVisuals
            ? AnswerOption(
                label: (o as ColorType).name.toUpperCase(),
                compact: true,
                onTap: () => _onAnswerSelected(o),
              )
            : ColorOptionTile(
                color: o as ColorType,
                onTap: () => _onAnswerSelected(o),
              );
      },
    );
  }

  Widget _gridDefault(bool isHardLetters) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: isHardLetters ? 1.35 : 1.8,
    ),
    itemCount: _question.options.length,
    itemBuilder: (context, index) {
      final option = _question.options[index];
      return AnswerOption(
        label: option.toString(),
        onTap: () => _onAnswerSelected(option),
      );
    },
  );

  Widget _grid(Widget Function(dynamic) builder) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1,
    ),
    itemCount: _question.options.length,
    itemBuilder: (context, i) => builder(_question.options[i]),
  );

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

  String _difficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SoftDecor extends StatelessWidget {
  final Color accent;
  const _SoftDecor({required this.accent});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return IgnorePointer(
      child: Stack(
        children: [
          _bubble(top: 10, left: -50, size: 200, opacity: 0.14),
          _bubble(top: h * 0.18, right: -70, size: 160, opacity: 0.12),
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
  }) => Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    ),
  );
}

class AnimatedStarChip extends StatefulWidget {
  final int score;
  const AnimatedStarChip({super.key, required this.score});

  @override
  State<AnimatedStarChip> createState() => _AnimatedStarChipState();
}

class _AnimatedStarChipState extends State<AnimatedStarChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _lastScore = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedStarChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score > _lastScore) _controller.forward(from: 0);
    _lastScore = widget.score;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              final t = _controller.value;
              final scale = 1 + (0.7 * (1 - (2 * (t - 0.5)).abs()));
              final rotation = 0.25 * sin(t * pi * 3);
              return Transform.scale(
                scale: scale,
                child: Transform.rotate(angle: rotation, child: child),
              );
            },
            child: const Text('⭐', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 6),
          Text(
            widget.score.toString(),
            style: GoogleFonts.fredoka(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

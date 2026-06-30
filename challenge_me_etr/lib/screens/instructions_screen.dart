import 'package:challenge_me_etr/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'main_screen.dart';
import 'tasks_history_screen.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen>
    with SingleTickerProviderStateMixin {
  bool isMenuOpen = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMenu() {
    if (isMenuOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => isMenuOpen = !isMenuOpen);
  }

  final List<Map<String, dynamic>> instructions = [
    {
      'icon': FontAwesomeIcons.handPointer,
      'title': 'Choose a Category',
      'description':
          'Pick a category that matches your mood — social, creative, physical, and more.',
      'color': const Color(0xFF81D4FA),
    },
    {
      'icon': FontAwesomeIcons.bolt,
      'title': 'Get a Challenge',
      'description':
          'Each category gives you a random challenge designed to be fun and motivating.',
      'color': const Color(0xFFFFCC80),
    },
    {
      'icon': FontAwesomeIcons.stopwatch,
      'title': 'Complete It',
      'description': 'Finish the challenge within the day or at your own pace.',
      'color': const Color(0xFFA5D6A7),
    },
    {
      'icon': FontAwesomeIcons.checkCircle,
      'title': 'Mark as Done',
      'description':
          'Once completed, mark it as done and keep track of your progress.',
      'color': const Color(0xFFCE93D8),
    },
    {
      'icon': FontAwesomeIcons.trophy,
      'title': 'Build Momentum',
      'description':
          'Complete more challenges to build habits, confidence, and motivation.',
      'color': const Color(0xFFFF90A0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4DD0E1), Color(0xFFFFB74D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTitle(),
                  const SizedBox(height: 25),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: instructions.length,
                      itemBuilder: (context, index) {
                        final item = instructions[index];
                        final isLeft = index % 2 == 0;
                        return _InstructionCard(
                          icon: item['icon'],
                          title: item['title'],
                          description: item['description'],
                          color: item['color'],
                          isLeft: isLeft,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          if (isMenuOpen)
            GestureDetector(
              onTap: toggleMenu,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          ..._buildFabMenu(),

          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: toggleMenu,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0, 6),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white24,
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _controller,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFabMenu() {
    final buttons = <Map<String, dynamic>>[
      {
        'icon': FontAwesomeIcons.house,
        'tooltip': 'Home',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        ),
      },
      {
        'icon': FontAwesomeIcons.circleQuestion,
        'tooltip': 'Instructions',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InstructionsScreen()),
        ),
      },
      {
        'icon': FontAwesomeIcons.history,
        'tooltip': 'History',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasksHistoryScreen()),
        ),
      },
      {
        'icon': FontAwesomeIcons.gamepad,
        'tooltip': 'Game Screen',
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        ),
      },
    ];

    final List<Widget> widgets = [];
    for (var i = 0; i < buttons.length; i++) {
      final double offset = 80.0 * (i + 1);
      widgets.add(
        Positioned(
          bottom: 20 + offset,
          right: 20,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 1.0 - i * 0.15, curve: Curves.easeOut),
            ),
            child: GestureDetector(
              onTap: buttons[i]['onTap'] as void Function()?,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFCC80), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: FaIcon(
                    buttons[i]['icon'] as IconData,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildTitle() {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 4,
          child: Text(
            'HOW IT WORKS',
            style: GoogleFonts.bahiana(
              fontSize: 55,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = Colors.black45,
            ),
          ),
        ),
        Text(
          'HOW IT WORKS',
          style: GoogleFonts.bahiana(
            fontSize: 55,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isLeft;

  const _InstructionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(1.0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 6),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white24,
            offset: Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Flexible(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              leading: isLeft
                  ? FaIcon(icon, size: 40, color: Colors.white)
                  : null,
              trailing: !isLeft
                  ? FaIcon(icon, size: 40, color: Colors.white)
                  : null,
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
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

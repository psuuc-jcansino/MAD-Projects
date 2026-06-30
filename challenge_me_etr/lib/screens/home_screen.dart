import 'package:challenge_me_etr/screens/categories_screen/category_screen.dart';
import 'package:challenge_me_etr/screens/tasks_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickalert/quickalert.dart';

import 'main_screen.dart';
import 'instructions_screen.dart';
import '../models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isMenuOpen = false;
  late AnimationController _controller;

  final List<CategoryModel> categories = CategoryModel.defaultCategories;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: ' QUICK TIP ',
          text: 'Choose a category and start your challenge!',
          confirmBtnText: 'GOT IT!',
          barrierDismissible: true,
          backgroundColor: Colors.white,
          titleColor: Colors.black,
          textColor: Colors.black,
          confirmBtnColor: const Color(0xFF4DD0E1),
          onConfirmBtnTap: () => Navigator.pop(context),
        );
      });
    });
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
                  const SizedBox(height: 30),
                  _buildTitle(),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _buildCategoryCard(context, category);
                        },
                      ),
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

  Widget _buildTitle() {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 4,
          child: Text(
            'START CHALLENGE',
            style: GoogleFonts.bahiana(
              fontSize: 60,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = Colors.black45,
            ),
          ),
        ),
        Text(
          'START CHALLENGE',
          style: GoogleFonts.bahiana(
            fontSize: 60,
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

  Widget _buildCategoryCard(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CategoryScreen(category: category)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [category.color.withOpacity(0.8), category.color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 6),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(category.icon, size: 50, color: Colors.white),
            const SizedBox(height: 15),
            Text(
              category.title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
          ],
        ),
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
}

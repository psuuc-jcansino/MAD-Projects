import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _shimmerController;
  late AnimationController _bottomFadeController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _shimmerPosition;
  late Animation<double> _bottomOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _bottomFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    _shimmerPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomFadeController, curve: Curves.easeOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    _bottomFadeController.forward();
    _shimmerController.forward();

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3000)),
      _waitForAuthState(),
    ]);

    _checkAuthStatus();
  }

  Future<void> _waitForAuthState() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null || !authProvider.isLoading) return;
    await Future.delayed(const Duration(milliseconds: 2000));
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    _bottomFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.68).clamp(200.0, 280.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E1A),
      body: Stack(
        children: [
          CustomPaint(
            painter: _GridPainter(),
            size: MediaQuery.of(context).size,
          ),

          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7F77DD).withOpacity(0.20),
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
                    const Color(0xFF1D9E75).withOpacity(0.13),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) => Transform.scale(
                scale: _logoScale.value,
                child: Opacity(opacity: _logoOpacity.value, child: child),
              ),
              child: Image.asset(
                'assets/icons/gekitou-logo.png',
                width: logoSize,
                height: logoSize,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: FadeTransition(
                opacity: _bottomOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        width: 100,
                        height: 2,
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, _) => CustomPaint(
                            painter: _ShimmerBarPainter(_shimmerPosition.value),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.0,
                        color: Colors.white.withOpacity(0.18),
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShimmerBarPainter extends CustomPainter {
  final double position;

  _ShimmerBarPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withOpacity(0.07),
    );

    final fillWidth = size.width * position;
    final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);

    canvas.drawRect(
      fillRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF7F77DD).withOpacity(0.9),
            const Color(0xFF1D9E75).withOpacity(0.9),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_ShimmerBarPainter old) => old.position != position;
}

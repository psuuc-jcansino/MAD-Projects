import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeOpacity;
  late Animation<Offset> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Registration failed'),
            backgroundColor: const Color(0xFFE24B4A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.35).clamp(100.0, 140.0);

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

          SafeArea(
            child: FadeTransition(
              opacity: _fadeOpacity,
              child: SlideTransition(
                position: _fadeSlide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white.withOpacity(0.55),
                                size: 15,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Image.asset(
                            'assets/icons/gekitou-logo.png',
                            width: logoSize,
                            height: logoSize,
                            filterQuality: FilterQuality.high,
                          ),
                          const Spacer(),
                          const SizedBox(width: 36),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'TURN-BASED ANIME BATTLES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.2,
                          color: Colors.white.withOpacity(0.28),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 0.5,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create account',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.88),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Join and start battling anime characters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),

                              const SizedBox(height: 24),

                              _buildLabel('Display Name'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _displayNameController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hint: 'Your fighter name',
                                  icon: Icons.person_outline_rounded,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Display name is required';
                                  }
                                  if (value!.length < 2) {
                                    return 'At least 2 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _buildLabel('Email'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(
                                  hint: 'you@example.com',
                                  icon: Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Email is required';
                                  }
                                  if (!value!.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _buildLabel('Password'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                obscureText: _obscurePassword,
                                decoration:
                                    _inputDecoration(
                                      hint: '••••••••',
                                      icon: Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.white.withOpacity(0.35),
                                          size: 18,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Password is required';
                                  }
                                  if (value!.length < 6) {
                                    return 'At least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _buildLabel('Confirm Password'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _confirmPasswordController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                obscureText: _obscureConfirmPassword,
                                decoration:
                                    _inputDecoration(
                                      hint: '••••••••',
                                      icon: Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: Colors.white.withOpacity(0.35),
                                          size: 18,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirmPassword =
                                              !_obscureConfirmPassword,
                                        ),
                                      ),
                                    ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading
                                          ? null
                                          : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1D9E75,
                                        ),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: const Color(
                                          0xFF1D9E75,
                                        ).withOpacity(0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                      Colors.white,
                                                    ),
                                              ),
                                            )
                                          : const Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.35),
                            ),
                            children: const [
                              TextSpan(text: 'Already have an account?  '),
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(
                                  color: Color(0xFF7F77DD),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.45),
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.25), size: 18),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.08),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF7F77DD), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 0.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
      ),
      errorStyle: const TextStyle(color: Color(0xFFE24B4A), fontSize: 11),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thinky_app/services/local_profile_service.dart';
import '../models/kid_profile.dart';
import '../constants/avatar.dart';

class AddKidScreen extends StatefulWidget {
  const AddKidScreen({super.key});

  @override
  State<AddKidScreen> createState() => _AddKidScreenState();
}

class _AddKidScreenState extends State<AddKidScreen> {
  final _scrollController = ScrollController();

  final _nameFocus = FocusNode();
  final _ageFocus = FocusNode();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '5');

  int _age = 5;
  String _selectedAvatar = kidAvatars.first;

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => _scrollToField(_nameFocus));
    _ageFocus.addListener(() => _scrollToField(_ageFocus));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameFocus.dispose();
    _ageFocus.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _scrollToField(FocusNode node) {
    if (!node.hasFocus) return;

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!_scrollController.hasClients) return;

      final context = node.context;
      if (context == null) return;

      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;

      final y = box.localToGlobal(Offset.zero).dy;
      final screenHeight = MediaQuery.of(context).size.height;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      final offset =
          _scrollController.offset +
          y -
          (screenHeight - keyboardHeight) / 2 +
          box.size.height / 2;

      _scrollController.animateTo(
        offset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _saveKid() async {
    if (!_isValid) return;

    final profile = KidProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      age: _age,
      avatar: _selectedAvatar,
    );

    await LocalProfileService.addProfile(profile);
    if (!mounted) return;
    Navigator.pop(context, profile);
  }

  InputDecoration _field(String hint, {bool isPlaceholder = false}) {
    const fieldColor = Color(0xFF3A5BA0);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.fredoka(
        fontSize: 18,
        color: isPlaceholder ? fieldColor.withOpacity(0.4) : fieldColor,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      counterText: "",
    );
  }

  Widget _label(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: GoogleFonts.nunito(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF3A5BA0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const fieldTextColor = Color(0xFF3A5BA0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6EC6FF), Color(0xFFFFF4D8)],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "New Profile",
                      style: GoogleFonts.fredoka(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 4),
                            blurRadius: 8,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Create a new profile",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 28),

                    _label("Choose an avatar"),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 108,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final currentIndex = kidAvatars.indexOf(
                                _selectedAvatar,
                              );
                              final prevIndex = (currentIndex - 1).clamp(
                                0,
                                kidAvatars.length - 1,
                              );
                              setState(
                                () => _selectedAvatar = kidAvatars[prevIndex],
                              );
                            },
                            child: const Icon(
                              Icons.chevron_left,
                              size: 36,
                              color: Color(0xFF3A5BA0),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 18),
                              itemCount: kidAvatars.length,
                              itemBuilder: (_, i) {
                                final avatar = kidAvatars[i];
                                final selected = avatar == _selectedAvatar;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedAvatar = avatar),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF3A5BA0)
                                            : Colors.transparent,
                                        width: 4,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'lib/assets/avatars/$avatar',
                                      width: 56,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final currentIndex = kidAvatars.indexOf(
                                _selectedAvatar,
                              );
                              final nextIndex = (currentIndex + 1).clamp(
                                0,
                                kidAvatars.length - 1,
                              );
                              setState(
                                () => _selectedAvatar = kidAvatars[nextIndex],
                              );
                            },
                            child: const Icon(
                              Icons.chevron_right,
                              size: 36,
                              color: Color(0xFF3A5BA0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    _label("What is your name?"),
                    const SizedBox(height: 10),
                    TextField(
                      focusNode: _nameFocus,
                      controller: _nameController,
                      decoration: _field("Your name", isPlaceholder: true),
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: fieldTextColor,
                      ),
                    ),
                    const SizedBox(height: 22),

                    _label("How old are you?"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AgeButton(
                          icon: Icons.remove,
                          onTap: _age > 3
                              ? () => setState(() {
                                  _age--;
                                  _ageController.text = '$_age';
                                })
                              : null,
                        ),
                        const SizedBox(width: 18),
                        SizedBox(
                          width: 84,
                          child: TextField(
                            focusNode: _ageFocus,
                            controller: _ageController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: _field("", isPlaceholder: true),
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              color: fieldTextColor,
                            ),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n >= 3 && n <= 12) _age = n;
                            },
                          ),
                        ),
                        const SizedBox(width: 18),
                        _AgeButton(
                          icon: Icons.add,
                          onTap: _age < 12
                              ? () => setState(() {
                                  _age++;
                                  _ageController.text = '$_age';
                                })
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleAction(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
                _CircleAction(
                  icon: Icons.check,
                  onTap: _isValid ? _saveKid : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _AgeButton({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: onTap != null
            ? const Color(0xFF3A5BA0).withOpacity(0.18)
            : Colors.grey.withOpacity(0.2),
        child: Icon(icon, size: 28, color: const Color(0xFF3A5BA0)),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleAction({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF3A5BA0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: Icon(icon, color: Colors.white, size: 30)),
      ),
    );
  }
}

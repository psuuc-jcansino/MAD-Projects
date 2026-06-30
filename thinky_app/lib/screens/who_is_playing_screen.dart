import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/kid_profile.dart';
import '../services/local_profile_service.dart';
import '../widgets/kid_avatar_card.dart';
import 'add_kid_screen.dart';
import 'home_screen.dart';

class WhoIsPlayingScreen extends StatefulWidget {
  const WhoIsPlayingScreen({super.key});

  @override
  State<WhoIsPlayingScreen> createState() => _WhoIsPlayingScreenState();
}

class _WhoIsPlayingScreenState extends State<WhoIsPlayingScreen> {
  List<KidProfile> profiles = [];
  String? selectedProfileId;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final loaded = await LocalProfileService.getProfiles();
    if (!mounted) return;
    setState(() => profiles = loaded);
  }

  KidProfile? get _selectedProfile {
    if (selectedProfileId == null || profiles.isEmpty) return null;
    try {
      return profiles.firstWhere((p) => p.id == selectedProfileId);
    } catch (_) {
      return profiles.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6EC6FF), Color(0xFFFFF4D8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _SoftDecor(),
              Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Who's playing?",
                    style: GoogleFonts.fredoka(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 3),
                          blurRadius: 6,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose your profile",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 28,
                            mainAxisSpacing: 28,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: profiles.length + 1,
                      itemBuilder: (_, index) {
                        if (index == profiles.length) {
                          return KidAvatarCard.add(
                            onTap: () async {
                              final beforeCount = profiles.length;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddKidScreen(),
                                ),
                              );
                              await _loadProfiles();
                              if (!mounted) return;
                              if (profiles.length > beforeCount) {
                                final newProfile = profiles.last;
                                _showWelcomePopup(context, newProfile.name);
                              }
                            },
                          );
                        }

                        final profile = profiles[index];

                        return KidAvatarCard(
                          profile: profile,
                          isSelected: selectedProfileId == profile.id,
                          onTap: () {
                            setState(() {
                              selectedProfileId =
                                  selectedProfileId == profile.id
                                  ? null
                                  : profile.id;
                            });
                          },
                          onDelete: () async {
                            await LocalProfileService.deleteProfile(profile.id);
                            if (!mounted) return;

                            setState(() => selectedProfileId = null);
                            await _loadProfiles();
                            if (!mounted) return;

                            _showDeletedPopup(context, profile.name);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleActionButton(
                        icon: FontAwesomeIcons.reply,
                        onTap: () => Navigator.pop(context),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: selectedProfileId == null
                            ? const SizedBox(width: 72, height: 72)
                            : _CircleActionButton(
                                key: ValueKey(selectedProfileId),
                                icon: FontAwesomeIcons.check,
                                onTap: () async {
                                  final profile = _selectedProfile;
                                  if (profile == null) return;

                                  final updatedProfile =
                                      await Navigator.push<KidProfile>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              HomeScreen(profile: profile),
                                        ),
                                      );

                                  if (!mounted) return;

                                  if (updatedProfile != null) {
                                    final index = profiles.indexWhere(
                                      (p) => p.id == updatedProfile.id,
                                    );
                                    if (index != -1) {
                                      setState(() {
                                        profiles[index] = updatedProfile;
                                        selectedProfileId = updatedProfile.id;
                                      });
                                    }
                                  }
                                },
                              ),
                      ),
                    ],
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

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF3A5BA0),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: FaIcon(icon, size: 26, color: Colors.white)),
      ),
    );
  }
}

class _SoftDecor extends StatelessWidget {
  const _SoftDecor();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return IgnorePointer(
      child: Stack(
        children: [
          _bubble(top: 1, left: -50, size: 200, opacity: 0.14),
          _bubble(top: h * 0.15, right: -70, size: 160, opacity: 0.12),
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
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF3A5BA0).withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

void _showWelcomePopup(BuildContext context, String name) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6EC6FF).withOpacity(0.25),
              ),
              child: const Icon(
                Icons.celebration,
                color: Color(0xFF3A5BA0),
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Welcome, $name!",
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3A5BA0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's have fun learning!",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A5BA0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Thanks!",
                  style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showDeletedPopup(BuildContext context, String name) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6EC6FF).withOpacity(0.25),
              ),
              child: const Icon(
                Icons.waving_hand_outlined,
                color: Color(0xFF3A5BA0),
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Thanks for playing, $name!",
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3A5BA0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "See you soon, buddy!",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A5BA0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "See you!",
                  style: GoogleFonts.fredoka(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

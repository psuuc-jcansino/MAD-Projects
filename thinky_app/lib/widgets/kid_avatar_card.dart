import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/kid_profile.dart';

class KidAvatarCard extends StatelessWidget {
  final KidProfile? profile;
  final VoidCallback onTap;
  final bool isSelected;
  final VoidCallback? onDelete;
  final bool isAdd;

  const KidAvatarCard({
    super.key,
    required this.profile,
    required this.onTap,
    this.isSelected = false,
    this.onDelete,
  }) : isAdd = false;

  const KidAvatarCard.add({super.key, required this.onTap})
    : profile = null,
      isSelected = false,
      onDelete = null,
      isAdd = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: isSelected
              ? Border.all(color: const Color(0xFF3A5BA0), width: 3)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: isAdd ? _add() : _profile(context),
      ),
    );
  }

  Widget _profile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerRight,
            child: isSelected && onDelete != null
                ? PopupMenuButton(
                    padding: EdgeInsets.zero,
                    icon: const FaIcon(
                      FontAwesomeIcons.ellipsisVertical,
                      size: 16,
                      color: Color(0xFF3A5BA0),
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Center(
                          child: Text(
                            "Delete Profile",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onSelected: (_) {
                      Future.delayed(const Duration(milliseconds: 120), () {
                        onDelete?.call();
                      });
                    },
                  )
                : const SizedBox(width: 24),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF6EC6FF).withOpacity(0.35),
          ),
          padding: const EdgeInsets.all(14),
          child: Image.asset('lib/assets/avatars/${profile!.avatar}'),
        ),
        const SizedBox(height: 10),

        Text(
          profile!.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3A5BA0),
          ),
        ),
      ],
    );
  }

  Widget _add() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF6EC6FF).withOpacity(0.35),
          ),
          child: const Icon(Icons.add, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 10),

        Text(
          "Add Profile",
          style: GoogleFonts.fredoka(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3A5BA0),
          ),
        ),
      ],
    );
  }
}

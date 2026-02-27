import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/widgets/dotted_background.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/app/routes/app_routes.dart';
import 'package:sewa_hub/features/auth/presentation/pages/login_page.dart';
import 'package:sewa_hub/core/utils/snackbar_utils.dart';
import 'package:sewa_hub/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:sewa_hub/features/profile/presentation/state/profile_state.dart';
import 'package:sewa_hub/features/profile/presentation/view_model/profile_view_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileState.status == ProfileStatus.initial) {
        ref.read(profileViewModelProvider.notifier).getProfile();
      }
    });

    final profile = profileState.profileEntity;
    final fullName = profile?.fullName ?? 'SewaHub User';
    final email = profile?.email ?? '';
    final imageUrl = profile?.profilePicture != null
        ? 'http://10.0.2.2:5050${profile!.profilePicture!}'
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: DottedBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Orange gradient header ───────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF9A6C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(36),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                    child: Column(
                      children: [
                        // Top bar
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Avatar
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _Initials(name: fullName),
                                )
                              : _Initials(name: fullName),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),

                        // Edit button
                        GestureDetector(
                          onTap: () => AppRoutes.push(
                              context, const EditProfilePage()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Menu sections ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Preferences'),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.palette_outlined,
                      label: 'Theme',
                      onTap: () {},
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: false,
                          onChanged: (_) {},
                          activeColor: _orange,
                        ),
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_none_outlined,
                      label: 'Notifications',
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),
                    const _SectionLabel('About'),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: 'About App',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      label: 'Terms & Conditions',
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),
                    const _SectionLabel('Account'),
                    const SizedBox(height: 8),

                    // Logout
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Color(0xFFEF4444), size: 18),
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: Color(0xFFEF4444), size: 18),
                        onTap: () async {
                          final authRepo = ref.read(authRepositoryProvider);
                          final result = await authRepo.logOut();
                          result.fold(
                            (failure) => SnackbarUtils.showError(context,
                                message: failure.message),
                            (success) {
                              if (success) {
                                SnackbarUtils.showSuccess(context,
                                    message: 'Logged out successfully');
                                AppRoutes.pushReplacement(
                                    context, const LoginScreen());
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _Initials extends StatelessWidget {
  final String name;
  const _Initials({required this.name});

  String get _text {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white.withOpacity(0.25),
        child: Center(
          child: Text(_text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.0,
          ),
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3EE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _orange, size: 18),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1), size: 18),
      ),
    );
  }
}
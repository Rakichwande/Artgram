import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/post_model.dart';
import '../theme/app_colors.dart';
import '../widgets/post_card.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final auth       = context.read<AuthService>();
    final firestore  = FirestoreService();
    final midColor   = isDark ? AppColors.darkTextMid  : AppColors.lightTextMid;
    final accent     = isDark ? AppColors.roseDark     : AppColors.rose;
    final bgColor    = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor  = isDark ? AppColors.darkBorder  : AppColors.lightBorder;
    final textPrimary  = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── Profile AppBar ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: surfaceColor,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        auth.currentUserEmail.split('@').first,
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    // ── Menu button ──────────────────────────────────────────
                    PopupMenuButton<String>(
                      icon: Icon(Icons.menu, color: textPrimary),
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: borderColor),
                      ),
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                            break;
                          case 'settings':
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Settings coming in Phase 2')));
                            break;
                          case 'logout':
                            await _confirmLogout(context, auth);
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18, color: accent),
                            const SizedBox(width: 12),
                            Text('Edit Profile', style: TextStyle(color: textPrimary, fontSize: 14)),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(children: [
                            Icon(Icons.settings_outlined, size: 18, color: textPrimary),
                            const SizedBox(width: 12),
                            Text('Settings', style: TextStyle(color: textPrimary, fontSize: 14)),
                          ]),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(children: [
                            const Icon(Icons.logout_outlined, size: 18, color: AppColors.error),
                            const SizedBox(width: 12),
                            const Text('Log Out',
                              style: TextStyle(color: AppColors.error, fontSize: 14,
                                fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Profile header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: surfaceColor,
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.roseLight,
                          child: Text(auth.currentUserInitials,
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700,
                              color: accent)),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: surfaceColor, width: 2),
                              ),
                              child: const Icon(Icons.edit, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Username
                    Text(auth.currentUserEmail.split('@').first,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                        color: textPrimary)),

                    const SizedBox(height: 4),
                    Text(auth.currentUserEmail,
                      style: TextStyle(fontSize: 12, color: midColor)),

                    const SizedBox(height: 6),
                    Text('Artist · ArtGram',
                      style: TextStyle(fontSize: 12, color: accent,
                        fontWeight: FontWeight.w500)),

                    const SizedBox(height: 20),

                    // Stats
                    FutureBuilder<List<PostModel>>(
                      future: firestore.getPostsByUser(auth.currentUserId),
                      builder: (context, snap) {
                        final count = snap.data?.length ?? 0;
                        final likes = snap.data?.fold<int>(0, (s, p) => s + p.likes) ?? 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Stat(value: '$count', label: 'Posts'),
                            Container(width: 1, height: 32,
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            _Stat(value: '$likes', label: 'Likes received'),
                            Container(width: 1, height: 32,
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            const _Stat(value: '0', label: 'Following'),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Edit profile button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Divider(color: borderColor, height: 1)),

            // ── My Artwork label ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Row(
                  children: [
                    Icon(Icons.grid_view_rounded, size: 18, color: textPrimary),
                    const SizedBox(width: 8),
                    Text('My Artwork',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: textPrimary)),
                  ],
                ),
              ),
            ),

            // ── Posts ────────────────────────────────────────────────────────
            FutureBuilder<List<PostModel>>(
              future: firestore.getPostsByUser(auth.currentUserId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.rose))));
                }

                final posts = snap.data ?? [];
                if (posts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(children: [
                        Icon(Icons.brush_outlined, size: 48,
                          color: isDark ? AppColors.darkTextLight : AppColors.lightTextLight),
                        const SizedBox(height: 12),
                        Text('No artwork posted yet.',
                          style: TextStyle(color: midColor, fontSize: 13)),
                      ]),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => PostCard(
                    post: posts[i],
                    isSaved: false,
                    onSaveToggled: (_) {},
                    ),
                    childCount: posts.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout with confirmation dialog ─────────────────────────────────────────
  Future<void> _confirmLogout(BuildContext context, AuthService auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMid : AppColors.lightTextMid)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log Out',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label,
        style: const TextStyle(fontSize: 11)),
    ]);
  }
}

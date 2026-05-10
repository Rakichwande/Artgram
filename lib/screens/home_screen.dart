import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/post_repository.dart';
import '../models/post_model.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/post_card.dart';
import '../widgets/categories_row.dart';
import '../widgets/empty_feed_state.dart';
import 'upload_screen.dart';
import 'discover_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int    _tab         = 0;
  // FIX 1: selectedTag lives here — never reset by tab switches
  String _selectedTag = 'All';
  final  _postRepo    = PostRepository();

  // FIX 4: saved posts tracked in memory (Phase 2 will persist to FastAPI)
  final Set<String> _savedPostIds = {};

  void _onSaveToggled(String postId) {
    setState(() {
      if (_savedPostIds.contains(postId)) {
        _savedPostIds.remove(postId);
      } else {
        _savedPostIds.add(postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg   = isDark ? AppColors.darkSurface    : AppColors.lightSurface;
    final feedBg      = isDark ? AppColors.darkFeed        : AppColors.lightFeed;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMid     = isDark ? AppColors.darkTextMid     : AppColors.lightTextMid;
    final accent      = isDark ? AppColors.roseDark        : AppColors.rose;

    return Scaffold(
      backgroundColor: feedBg,
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: () => setState(() => _tab = 2),
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add_photo_alternate_outlined, size: 26),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: surfaceBg,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Row(
                children: [
                  Text('ArtGram',
                    style: Theme.of(context).appBarTheme.titleTextStyle),
                  const Spacer(),
                  _AppBarIcon(
                    icon: Icons.search_outlined,
                    color: textPrimary,
                    onTap: () => setState(() => _tab = 1),
                  ),
                  const SizedBox(width: 12),
                  _AppBarIcon(
                    icon: Icons.notifications_outlined,
                    color: textPrimary,
                    onTap: () => setState(() => _tab = 3),
                  ),
                  const SizedBox(width: 12),
                  _AppBarIcon(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: textMid,
                    onTap: () => context.read<ThemeProvider>().toggle(),
                  ),
                ],
              ),
            ),

            // Tab body — FIX 1: feed tab is always index 0 in stack
            // selectedTag is passed down and never lost
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _FeedTab(
                    postRepo:        _postRepo,
                    selectedTag:     _selectedTag,
                    savedPostIds:    _savedPostIds,
                    onTagChanged:    (tag) => setState(() => _selectedTag = tag),
                    onSaveToggled:   _onSaveToggled,
                  ),
                  const DiscoverScreen(),
                  UploadScreen(
                    isTab: true,
                    onUploadSuccess: () => setState(() => _tab = 0),
                  ),
                  const NotificationsScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),

            // Bottom nav
            _BottomNav(
              currentTab:    _tab,
              accent:        accent,
              surfaceBg:     surfaceBg,
              textPrimary:   textPrimary,
              isDark:        isDark,
              onTabSelected: (i) => setState(() => _tab = i),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feed tab ──────────────────────────────────────────────────────────────────
class _FeedTab extends StatelessWidget {
  final PostRepository   postRepo;
  final String           selectedTag;
  final Set<String>      savedPostIds;
  final ValueChanged<String> onTagChanged;
  final ValueChanged<String> onSaveToggled;

  const _FeedTab({
    required this.postRepo,
    required this.selectedTag,
    required this.savedPostIds,
    required this.onTagChanged,
    required this.onSaveToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final midColor   = isDark ? AppColors.darkTextMid   : AppColors.lightTextMid;
    final lightColor = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;

    return StreamBuilder<List<PostModel>>(
      stream: postRepo.getPostsByTagStream(selectedTag),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.rose));
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.wifi_off_outlined, size: 48, color: lightColor),
              const SizedBox(height: 12),
              Text('Could not load posts',
                style: TextStyle(color: midColor, fontSize: 13)),
            ]),
          );
        }

        final posts = snapshot.data ?? [];

        return CustomScrollView(
          // FIX 1: PageStorageKey preserves scroll position across tab switches
          key: PageStorageKey<String>('feed_$selectedTag'),
          slivers: [
            SliverToBoxAdapter(
              child: CategoriesRow(
                selectedTag:         selectedTag,
                onCategorySelected:  onTagChanged,
              ),
            ),
            if (posts.isEmpty)
              const SliverFillRemaining(child: EmptyFeedState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => PostCard(
                    post:          posts[i],
                    isSaved:       savedPostIds.contains(posts[i].id),
                    onSaveToggled: onSaveToggled,
                  ),
                  childCount: posts.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int     currentTab;
  final Color   accent, surfaceBg, textPrimary;
  final bool    isDark;
  final ValueChanged<int> onTabSelected;

  const _BottomNav({
    required this.currentTab,
    required this.accent,
    required this.surfaceBg,
    required this.textPrimary,
    required this.isDark,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? AppColors.darkTextLight
        : AppColors.lightTextLight;

    final tabs = [
      _NavTab(icon: Icons.home_outlined,         activeIcon: Icons.home),
      _NavTab(icon: Icons.explore_outlined,       activeIcon: Icons.explore),
      _NavTab(icon: Icons.add_box_outlined,       activeIcon: Icons.add_box),
      _NavTab(icon: Icons.notifications_outlined, activeIcon: Icons.notifications),
      _NavTab(icon: Icons.person_outline,         activeIcon: Icons.person),
    ];

    return Container(
      color: surfaceBg,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final active = currentTab == i;
          return GestureDetector(
            onTap: () => onTabSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? accent.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                active ? tabs[i].activeIcon : tabs[i].icon,
                size: 24,
                color: active ? accent : inactiveColor,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavTab {
  final IconData icon, activeIcon;
  const _NavTab({required this.icon, required this.activeIcon});
}

class _AppBarIcon extends StatelessWidget {
  final IconData   icon;
  final Color      color;
  final VoidCallback onTap;
  const _AppBarIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: onTap,
        child: Icon(icon, size: 22, color: color));
}

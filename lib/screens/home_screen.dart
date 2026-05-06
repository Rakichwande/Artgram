import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/post_card.dart';
import '../widgets/story_item.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  // ── Sample feed data ───────────────────────────────────────────────────────
  final List<PostData> _posts = const [
    PostData(
      initials: 'KL',
      username: '@klee_art',
      timeAgo: '2h ago',
      avatarBg: AppColors.av1Bg,
      avatarFg: AppColors.av1Fg,
      artworkGradient: [
        Color(0xFFF5D5CC),
        Color(0xFFE8B4A8),
        Color(0xFFC97B6E),
      ],
      caption: 'New oil painting — golden hour series 🌅 #OilPainting #AbstractArt',
      likeCount: 248,
      commentCount: 34,
      isLiked: true,
    ),
    PostData(
      initials: 'MV',
      username: '@monet_v',
      timeAgo: '5h ago',
      avatarBg: AppColors.av2Bg,
      avatarFg: AppColors.av2Fg,
      artworkGradient: [
        Color(0xFFD4E8F0),
        Color(0xFFA8C8DE),
        Color(0xFF7EB0D4),
      ],
      caption:
          'Watercolour studies, experimenting with negative space ✨ #Watercolour #ArtStudy',
      likeCount: 112,
      commentCount: 19,
    ),
    PostData(
      initials: 'RD',
      username: '@r.draw',
      timeAgo: '8h ago',
      avatarBg: AppColors.av4Bg,
      avatarFg: AppColors.av4Fg,
      artworkGradient: [
        Color(0xFFF0E6D0),
        Color(0xFFE0C89A),
        Color(0xFFC4A46E),
      ],
      caption:
          'Charcoal landscape, dawn mood 🖤 #Charcoal #Landscape #TraditionalArt',
      likeCount: 67,
      commentCount: 8,
    ),
    PostData(
      initials: 'SB',
      username: '@skbk',
      timeAgo: '12h ago',
      avatarBg: AppColors.av3Bg,
      avatarFg: AppColors.av3Fg,
      artworkGradient: [
        Color(0xFFD8EFD0),
        Color(0xFFB4DCA8),
        Color(0xFF7CC472),
      ],
      caption:
          'Sketchbook page 47 — loose gesture drawings 🖊 #Sketchbook #GestureDrawing',
      likeCount: 189,
      commentCount: 22,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.feedBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────
            _buildAppBar(),

            // ── Feed content ─────────────────────────────────────────────
            Expanded(
              child: _currentTab == 0 ? _buildFeedTab() : _buildPlaceholderTab(),
            ),

            // ── Bottom navigation ─────────────────────────────────────────
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ArtGram', style: AppTextStyles.brandAppBar),
          Row(
            children: [
              _IconButton(icon: Icons.chat_bubble_outline, onTap: () {}),
              const SizedBox(width: 14),
              _IconButton(icon: Icons.favorite_border, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  // ── Main feed tab ─────────────────────────────────────────────────────────
  Widget _buildFeedTab() {
    return CustomScrollView(
      slivers: [
        // Stories row
        SliverToBoxAdapter(child: _buildStoriesRow()),

        // Post cards
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => PostCard(post: _posts[index]),
            childCount: _posts.length,
          ),
        ),
      ],
    );
  }

  // ── Stories row ───────────────────────────────────────────────────────────
  Widget _buildStoriesRow() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: const [
            StoryItem(
              initials: '+',
              name: 'Your story',
              isAddButton: true,
            ),
            SizedBox(width: 10),
            StoryItem(
              initials: 'KL',
              name: '@klee_art',
              avatarBg: AppColors.av1Bg,
              avatarFg: AppColors.av1Fg,
            ),
            SizedBox(width: 10),
            StoryItem(
              initials: 'MV',
              name: '@monet_v',
              avatarBg: AppColors.av2Bg,
              avatarFg: AppColors.av2Fg,
            ),
            SizedBox(width: 10),
            StoryItem(
              initials: 'RD',
              name: '@r.draw',
              avatarBg: AppColors.av4Bg,
              avatarFg: AppColors.av4Fg,
            ),
            SizedBox(width: 10),
            StoryItem(
              initials: 'SB',
              name: '@skbk',
              avatarBg: AppColors.av3Bg,
              avatarFg: AppColors.av3Fg,
            ),
          ],
        ),
      ),
    );
  }

  // ── Placeholder for other tabs ────────────────────────────────────────────
  Widget _buildPlaceholderTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_outlined, size: 48, color: AppColors.light),
          const SizedBox(height: 12),
          Text(
            'Coming soon',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }

  // ── Bottom navigation bar ─────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const tabs = [
      _NavTab(icon: Icons.home_outlined,      activeIcon: Icons.home),
      _NavTab(icon: Icons.search,             activeIcon: Icons.search),
      _NavTab(icon: Icons.add_box_outlined,   activeIcon: Icons.add_box),
      _NavTab(icon: Icons.tv_outlined,        activeIcon: Icons.tv),
      _NavTab(icon: Icons.person_outline,     activeIcon: Icons.person),
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final isActive = _currentTab == i;
          return GestureDetector(
            onTap: () {
              if (i == 2) {
                // Upload tab — navigate to upload screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                );
                return;
              }
              setState(() => _currentTab = i);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? tabs[i].activeIcon : tabs[i].icon,
                  size: 22,
                  color: isActive ? AppColors.charcoal : AppColors.light,
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 3.5,
                    height: 3.5,
                    decoration: const BoxDecoration(
                      color: AppColors.charcoal,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  const _NavTab({required this.icon, required this.activeIcon});
}

// ── Small icon button for the app bar ────────────────────────────────────────
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 20, color: AppColors.charcoal),
      ),
    );
  }
}

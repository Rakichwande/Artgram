import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Data model for a single post in the feed
class PostData {
  final String initials;
  final String username;
  final String timeAgo;
  final Color avatarBg;
  final Color avatarFg;
  final List<Color> artworkGradient;
  final String caption;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const PostData({
    required this.initials,
    required this.username,
    required this.timeAgo,
    required this.avatarBg,
    required this.avatarFg,
    required this.artworkGradient,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
  });
}

/// Reusable post card widget used in the home feed
class PostCard extends StatefulWidget {
  final PostData post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.isLiked;
    _likes = widget.post.likeCount;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Post header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 17,
                  backgroundColor: widget.post.avatarBg,
                  child: Text(
                    widget.post.initials,
                    style: AppTextStyles.username.copyWith(
                      fontSize: 12,
                      color: widget.post.avatarFg,
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                // Username + timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.username, style: AppTextStyles.username),
                      Text(widget.post.timeAgo,  style: AppTextStyles.timestamp),
                    ],
                  ),
                ),

                // Three-dot menu
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 3,
                      height: 3,
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      decoration: const BoxDecoration(
                        color: AppColors.mid,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Artwork placeholder ──────────────────────────────────────────
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.post.artworkGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(40, 40),
                  painter: _ArtworkIconPainter(widget.post.artworkGradient.last),
                ),
              ),
            ),
          ),

          // ── Action row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                // Like
                _ActionButton(
                  icon: _liked ? Icons.favorite : Icons.favorite_border,
                  iconColor: _liked ? AppColors.rose : AppColors.charcoal,
                  count: _likes.toString(),
                  onTap: _toggleLike,
                ),

                const SizedBox(width: 14),

                // Comment
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.charcoal,
                  count: widget.post.commentCount.toString(),
                  onTap: () {},
                ),

                const Spacer(),

                // Share / save
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.bookmark_border,
                    size: 20,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),

          // ── Caption ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.caption,
                children: [
                  TextSpan(
                    text: '${widget.post.username} ',
                    style: AppTextStyles.caption
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),

          // Bottom border
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

// ── Action button (like / comment) ──────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 5),
          Text(count, style: AppTextStyles.actionCount),
        ],
      ),
    );
  }
}

// ── Decorative icon painted on the artwork area ──────────────────────────────
class _ArtworkIconPainter extends CustomPainter {
  final Color baseColor;
  const _ArtworkIconPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Simple wave line as abstract art indicator
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2,
      size.width * 0.5,  size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.8,
      size.width,        size.height * 0.4,
    );
    canvas.drawPath(path, paint);

    // Outer faint circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint..color = Colors.white.withOpacity(0.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

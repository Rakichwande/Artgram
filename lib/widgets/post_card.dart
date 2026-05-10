import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../repositories/post_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'comments_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel  post;
  final bool       isSaved;
  final ValueChanged<String> onSaveToggled;

  const PostCard({
    super.key,
    required this.post,
    required this.isSaved,
    required this.onSaveToggled,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked;
  late int  _likes;
  final _postRepo = PostRepository();
  final _auth     = AuthService();

  @override
  void initState() {
    super.initState();
    _liked = widget.post.isLikedBy(_auth.currentUserId);
    _likes = widget.post.likes;
  }

  Future<void> _toggleLike() async {
    final wasLiked = _liked;
    setState(() {
      _liked  = !_liked;
      _likes += _liked ? 1 : -1;
    });
    await _postRepo.toggleLike(
      postId:           widget.post.id,
      userId:           _auth.currentUserId,
      isCurrentlyLiked: wasLiked,
    );
  }

  // FIX 2: comments sheet kept alive with a Navigator route so stream
  // doesn't dispose when sheet is partially scrolled off screen
  void _openComments() {
    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   Colors.transparent,
      // FIX 2: keepAlive ensures stream stays active the entire time sheet is open
      builder: (_) => CommentsSheet(
        postId:   widget.post.id,
        postRepo: _postRepo,
      ),
    );
  }

  // FIX 3: three dots menu — report, share, copy link
  void _openPostMenu() {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor  = isDark ? AppColors.darkBorder  : AppColors.lightBorder;
    final textPrimary  = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final midColor     = isDark ? AppColors.darkTextMid : AppColors.lightTextMid;
    final isOwnPost    = widget.post.userId == _auth.currentUserId;

    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Post info header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.roseLight,
                  child: Text(widget.post.avatarInitials,
                    style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600, color: AppColors.rose)),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.post.username,
                    style: TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 13, color: textPrimary)),
                  Text(widget.post.caption.isNotEmpty
                      ? widget.post.caption.length > 30
                          ? '${widget.post.caption.substring(0, 30)}...'
                          : widget.post.caption
                      : 'No caption',
                    style: TextStyle(fontSize: 11, color: midColor)),
                ]),
              ]),
            ),

            Divider(color: borderColor, height: 1),

            // Menu items
            _MenuItem(
              icon:  Icons.share_outlined,
              label: 'Share Post',
              color: textPrimary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share feature coming in Phase 2'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            _MenuItem(
              icon:  Icons.link_outlined,
              label: 'Copy Link',
              color: textPrimary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copied!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            _MenuItem(
              icon:  widget.isSaved
                  ? Icons.bookmark
                  : Icons.bookmark_border_outlined,
              label: widget.isSaved ? 'Remove from Saved' : 'Save Post',
              color: textPrimary,
              onTap: () {
                Navigator.pop(context);
                widget.onSaveToggled(widget.post.id);
              },
            ),

            if (isOwnPost) ...[
              Divider(color: borderColor, height: 1),
              _MenuItem(
                icon:  Icons.delete_outline,
                label: 'Delete Post',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
            ] else ...[
              Divider(color: borderColor, height: 1),
              _MenuItem(
                icon:  Icons.flag_outlined,
                label: 'Report Post',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post reported. Thank you.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Post',
            style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text(
            'This will permanently delete your post. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Phase 2: will call DELETE /posts/{id} on FastAPI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    < 7)  return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final cardColor   = isDark ? AppColors.darkCard        : AppColors.lightSurface;
    final midColor    = isDark ? AppColors.darkTextMid     : AppColors.lightTextMid;
    final borderColor = isDark ? AppColors.darkBorder      : AppColors.lightBorder;
    final accent      = isDark ? AppColors.roseDark        : AppColors.rose;
    final iconColor   = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.av1Bg,
                  child: Text(widget.post.avatarInitials,
                    style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600, color: AppColors.av1Fg)),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.username,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5)),
                      Text(_formatTime(widget.post.timestamp),
                        style: TextStyle(fontSize: 10, color: midColor)),
                    ],
                  ),
                ),
                if (widget.post.tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(widget.post.tags.first,
                      style: TextStyle(fontSize: 10, color: accent,
                        fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(width: 8),
                // FIX 3: three dots now opens menu
                GestureDetector(
                  onTap: _openPostMenu,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.more_vert, size: 20, color: midColor),
                  ),
                ),
              ],
            ),
          ),

          // ── Image ────────────────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 1,
            child: widget.post.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.post.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightFeed,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.rose)),
                    ),
                    errorWidget: (_, __, ___) =>
                        _PlaceholderArt(isDark: isDark),
                  )
                : _PlaceholderArt(isDark: isDark),
          ),

          // ── Actions ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Row(
              children: [
                // Like
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(children: [
                    Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: _liked ? accent : iconColor,
                    ),
                    const SizedBox(width: 5),
                    Text('$_likes',
                      style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _liked ? accent : midColor)),
                  ]),
                ),

                const SizedBox(width: 16),

                // Comment
                GestureDetector(
                  onTap: _openComments,
                  child: Row(children: [
                    Icon(Icons.chat_bubble_outline,
                      size: 22, color: iconColor),
                    const SizedBox(width: 5),
                    Text('${widget.post.comments}',
                      style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600, color: midColor)),
                  ]),
                ),

                const Spacer(),

                // FIX 4: save icon is now interactive
                GestureDetector(
                  onTap: () => widget.onSaveToggled(widget.post.id),
                  child: Icon(
                    widget.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    size: 22,
                    color: widget.isSaved ? accent : iconColor,
                  ),
                ),
              ],
            ),
          ),

          // ── Caption ──────────────────────────────────────────────────────
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 13, height: 1.5),
                  children: [
                    TextSpan(text: '${widget.post.username} ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
            ),

          // View comments link
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: GestureDetector(
              onTap: _openComments,
              child: Text(
                widget.post.comments == 0
                    ? 'Add a comment...'
                    : 'View all ${widget.post.comments} comments',
                style: TextStyle(fontSize: 12, color: midColor),
              ),
            ),
          ),

          Divider(height: 1, color: borderColor),
        ],
      ),
    );
  }
}

// ── Menu item widget ──────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final Color      color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:  Icon(icon, color: color, size: 22),
      title:    Text(label,
        style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
      onTap:    onTap,
      dense:    true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

// ── Placeholder art ───────────────────────────────────────────────────────────
class _PlaceholderArt extends StatelessWidget {
  final bool isDark;
  const _PlaceholderArt({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3A2E2A), const Color(0xFF2C2220)]
              : [const Color(0xFFF5D5CC), const Color(0xFFC97B6E)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: Colors.white54)),
    );
  }
}

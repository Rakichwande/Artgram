import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/comment_model.dart';
import '../repositories/post_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class CommentsSheet extends StatefulWidget {
  final String         postId;
  final PostRepository postRepo;

  const CommentsSheet({
    super.key,
    required this.postId,
    required this.postRepo,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _textCtrl    = TextEditingController();
  final _auth        = AuthService();
  final _focusNode   = FocusNode();
  final _scrollCtrl  = ScrollController();
  bool  _posting     = false;

  // FIX 2: store comments locally once loaded — stream updates them
  // but we never lose them when sheet scrolls
  List<CommentModel> _comments = [];

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _posting) return;

    _textCtrl.clear();
    setState(() => _posting = true);

    final comment = CommentModel(
      id:             '',
      postId:         widget.postId,
      userId:         _auth.currentUserId,
      username:       _auth.currentUserEmail.split('@').first,
      avatarInitials: _auth.currentUserInitials,
      text:           text,
      timestamp:      DateTime.now(),
    );

    await widget.postRepo.addComment(comment);

    if (!mounted) return;
    setState(() => _posting = false);

    // Scroll to bottom after posting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours   < 24) return '${diff.inHours}h';
    if (diff.inDays    < 7)  return '${diff.inDays}d';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final bgColor      = isDark ? AppColors.darkSurface     : AppColors.lightSurface;
    final borderColor  = isDark ? AppColors.darkBorder      : AppColors.lightBorder;
    final midColor     = isDark ? AppColors.darkTextMid     : AppColors.lightTextMid;
    final textPrimary  = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accent       = isDark ? AppColors.roseDark        : AppColors.rose;
    final lightColor   = isDark ? AppColors.darkTextLight   : AppColors.lightTextLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize:     0.4,
      maxChildSize:     0.95,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24)),
          ),
          child: Column(
            children: [

              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Title row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(children: [
                  Text('Comments',
                    style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700, color: textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: midColor, size: 20)),
                ]),
              ),
              Divider(color: borderColor, height: 20),

              // FIX 2: StreamBuilder stores data into _comments list
              // even when widget partially scrolls — data is never lost
              Expanded(
                child: StreamBuilder<List<CommentModel>>(
                  stream: widget.postRepo.getCommentsStream(widget.postId),
                  builder: (context, snapshot) {
                    // Update local list whenever stream emits
                    if (snapshot.hasData) {
                      _comments = snapshot.data!;
                    }

                    if (snapshot.connectionState == ConnectionState.waiting
                        && _comments.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.rose, strokeWidth: 2));
                    }

                    if (_comments.isEmpty) {
                      return Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.chat_bubble_outline,
                            size: 40, color: lightColor),
                          const SizedBox(height: 12),
                          Text('No comments yet. Be the first!',
                            style: TextStyle(color: midColor, fontSize: 13)),
                        ]),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _comments.length,
                      itemBuilder: (_, i) {
                        final c   = _comments[i];
                        final own = c.userId == _auth.currentUserId;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.roseLight,
                                child: Text(c.avatarInitials,
                                  style: const TextStyle(fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.rose)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(fontSize: 13,
                                          color: textPrimary, height: 1.4),
                                        children: [
                                          TextSpan(text: '${c.username} ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700)),
                                          TextSpan(text: c.text),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(_formatTime(c.timestamp),
                                      style: TextStyle(
                                        fontSize: 11, color: midColor)),
                                  ],
                                ),
                              ),
                              if (own)
                                GestureDetector(
                                  onTap: () => widget.postRepo.deleteComment(
                                    commentId: c.id,
                                    postId:    widget.postId,
                                  ),
                                  child: Icon(Icons.delete_outline,
                                    size: 16, color: midColor),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Input
              Divider(color: borderColor, height: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16, 10, 16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.roseLight,
                    child: Text(_auth.currentUserInitials,
                      style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600, color: AppColors.rose)),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _textCtrl,
                      builder: (_, value, __) {
                        return TextField(
                          controller: _textCtrl,
                          focusNode:  _focusNode,
                          maxLines:   null,
                          maxLength:  300,
                          style: TextStyle(fontSize: 14, color: textPrimary),
                          decoration: InputDecoration(
                            hintText:    'Add a comment...',
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: accent, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkCard
                                : AppColors.lightFeed,
                          ),
                          onSubmitted: (_) => _postComment(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textCtrl,
                    builder: (_, value, __) {
                      final hasText = value.text.trim().isNotEmpty;
                      return GestureDetector(
                        onTap: _posting ? null : _postComment,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: hasText ? accent : borderColor,
                            shape: BoxShape.circle,
                          ),
                          child: _posting
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

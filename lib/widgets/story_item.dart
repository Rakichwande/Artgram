import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A single story bubble shown in the horizontal stories row
class StoryItem extends StatelessWidget {
  final String initials;
  final String name;
  final Color avatarBg;
  final Color avatarFg;
  final bool isAddButton;

  const StoryItem({
    super.key,
    required this.initials,
    required this.name,
    this.avatarBg = AppColors.border,
    this.avatarFg = AppColors.mid,
    this.isAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ring or dashed border
          isAddButton
              ? _AddStoryBubble()
              : _StoryRing(
                  initials: initials,
                  avatarBg: avatarBg,
                  avatarFg: avatarFg,
                ),

          const SizedBox(height: 5),

          // Name label
          SizedBox(
            width: 48,
            child: Text(
              name,
              style: AppTextStyles.storyName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Story ring with gradient border ─────────────────────────────────────────
class _StoryRing extends StatelessWidget {
  final String initials;
  final Color avatarBg;
  final Color avatarFg;

  const _StoryRing({
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.rose, AppColors.roseSoft, Color(0xFFD4A08A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
        ),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: avatarBg,
          child: Text(
            initials,
            style: AppTextStyles.username.copyWith(
              fontSize: 13,
              color: avatarFg,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add story button (dashed circle) ────────────────────────────────────────
class _AddStoryBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: AppColors.rose,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.roseSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashCount = 12;
    const dashLength = 0.2;
    final gapLength = (2 * 3.14159 / dashCount) - dashLength;
    double angle = 0;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        angle,
        dashLength,
        false,
        paint,
      );
      angle += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

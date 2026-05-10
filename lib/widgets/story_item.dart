import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
    this.avatarBg = AppColors.av1Bg,
    this.avatarFg = AppColors.av1Fg,
    this.isAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isAddButton ? _AddBubble() : _RingBubble(initials: initials, bg: avatarBg, fg: avatarFg),
          const SizedBox(height: 5),
          SizedBox(
            width: 48,
            child: Text(name,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingBubble extends StatelessWidget {
  final String initials;
  final Color bg, fg;
  const _RingBubble({required this.initials, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 48, height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.rose, AppColors.roseSoft, Color(0xFFD4A08A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: isDark ? AppColors.darkSurface : Colors.white),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: bg,
          child: Text(initials, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ),
      ),
    );
  }
}

class _AddBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.roseSoft, width: 1.5),
        color: isDark ? AppColors.darkCard : AppColors.roseLight,
      ),
      child: const Center(child: Text('+', style: TextStyle(fontSize: 22, color: AppColors.rose, height: 1))),
    );
  }
}

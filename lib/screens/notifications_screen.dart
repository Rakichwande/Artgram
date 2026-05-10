import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgColor  = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final midColor = isDark ? AppColors.darkTextMid    : AppColors.lightTextMid;
    final lightColor = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;

    // Placeholder notifications — Phase 2 will load these from FastAPI
    final notifications = [
      _NotifData(initials: 'KL', text: '@klee_art liked your artwork', time: '2m ago',  icon: Icons.favorite, color: AppColors.rose),
      _NotifData(initials: 'MV', text: '@monet_v started following you', time: '1h ago', icon: Icons.person_add_outlined, color: Color(0xFF5C8DB3)),
      _NotifData(initials: 'RD', text: '@r.draw commented on your post', time: '3h ago', icon: Icons.chat_bubble_outline, color: Color(0xFF6B8F71)),
      _NotifData(initials: 'SB', text: '@skbk saved your artwork', time: '1d ago',  icon: Icons.bookmark_outline, color: Color(0xFFB3905C)),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Text('Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                itemBuilder: (context, i) {
                  final n = notifications[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.roseLight,
                      child: Text(n.initials,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.rose)),
                    ),
                    title: Text(n.text,
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                    subtitle: Text(n.time, style: TextStyle(fontSize: 11, color: midColor)),
                    trailing: Icon(n.icon, color: n.color, size: 20),
                  );
                },
              ),
            ),

            // Phase 2 note
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('Real notifications coming in Phase 2',
                  style: TextStyle(fontSize: 11, color: lightColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifData {
  final String initials, text, time;
  final IconData icon;
  final Color color;
  const _NotifData({required this.initials, required this.text, required this.time, required this.icon, required this.color});
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmptyFeedState extends StatelessWidget {
  const EmptyFeedState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final accent   = isDark ? AppColors.roseDark    : AppColors.rose;
    final midColor = isDark ? AppColors.darkTextMid : AppColors.lightTextMid;
    final lightColor = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.roseLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.palette_outlined, size: 48, color: accent),
            ),

            const SizedBox(height: 24),

            Text('No artwork yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Share your first artwork and inspire other artists.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: midColor, height: 1.5),
            ),

            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Upload Your First Artwork'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            Text('or follow artists to see their work here',
              style: TextStyle(fontSize: 12, color: lightColor),
            ),
          ],
        ),
      ),
    );
  }
}

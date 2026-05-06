import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Main centered content ──────────────────────────────────────
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App icon box
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(40, 40),
                          painter: _LogoIconPainter(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Brand name
                    Text('ArtGram', style: AppTextStyles.brandLarge),

                    const SizedBox(height: 4),

                    // Tagline
                    Text(
                      'SHARE YOUR CANVAS',
                      style: AppTextStyles.tagline,
                    ),

                    const SizedBox(height: 40),

                    // Accent dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.rose,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Column(
                children: [
                  // Get started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.charcoal,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Get Started', style: AppTextStyles.buttonPrimary),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'FROM ARTGRAM STUDIO',
                    style: AppTextStyles.tagline.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom painter for the logo icon ────────────────────────────────────────
class _LogoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppColors.rose
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.rose
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = AppColors.roseSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), 12, strokePaint);

    // Inner filled circle
    canvas.drawCircle(Offset(cx, cy), 5, fillPaint);

    // Decorative arc 1
    final path1 = Path();
    path1.moveTo(cx - 12, cy);
    path1.quadraticBezierTo(cx - 6, cy - 10, cx, cy - 6);
    canvas.drawPath(path1, accentPaint);

    // Decorative arc 2
    final path2 = Path();
    path2.moveTo(cx + 12, cy);
    path2.quadraticBezierTo(cx + 6, cy + 10, cx, cy + 6);
    canvas.drawPath(path2, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeIn,
    );

    _ctrl.forward();

    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(40, 40),
                            painter: _LogoPainter(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ArtGram',
                        style: Theme.of(context)
                            .appBarTheme
                            .titleTextStyle
                            ?.copyWith(
                              fontSize: 42,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SHARE YOUR CANVAS',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppColors.darkTextMid
                              : AppColors.lightTextMid,
                        ),
                      ),
                      const SizedBox(height: 40),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        isDark ? AppColors.roseDark : AppColors.rose,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.rose
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = AppColors.rose
      ..style = PaintingStyle.fill;

    final accent = Paint()
      ..color = AppColors.roseSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      12,
      stroke,
    );

    canvas.drawCircle(
      Offset(cx, cy),
      5,
      fill,
    );

    canvas.drawPath(
      Path()
        ..moveTo(cx - 12, cy)
        ..quadraticBezierTo(cx - 6, cy - 10, cx, cy - 6),
      accent,
    );

    canvas.drawPath(
      Path()
        ..moveTo(cx + 12, cy)
        ..quadraticBezierTo(cx + 6, cy + 10, cx, cy + 6),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Rose accent bar at top ─────────────────────────────────────
            Container(
              height: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.rose, AppColors.roseSoft, AppColors.roseLight],
                ),
              ),
            ),

            // ── Scrollable form content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small brand label
                    Text('ArtGram', style: AppTextStyles.brandAccent),

                    const SizedBox(height: 12),

                    // Headline
                    Text(
                      'Welcome\nback, artist.',
                      style: AppTextStyles.headline,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Sign in to continue sharing your work',
                      style: AppTextStyles.subtitle,
                    ),

                    const SizedBox(height: 32),

                    // ── Email field ──────────────────────────────────────
                    _FieldLabel(label: 'EMAIL'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _emailController,
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 14),

                    // ── Password field ───────────────────────────────────
                    _FieldLabel(label: 'PASSWORD'),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _passwordController,
                      hint: '••••••••',
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.mid,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('Forgot password?', style: AppTextStyles.linkAccent),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Sign in button ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
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
                        child: Text('Sign In', style: AppTextStyles.buttonPrimary),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '— or continue with —',
                            style: AppTextStyles.footerLink
                                .copyWith(color: AppColors.light, fontSize: 11),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Google button ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: _GoogleIcon(),
                        label: Text(
                          'Continue with Google',
                          style: AppTextStyles.buttonSecondary,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign up footer
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.footerLink,
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign up free',
                              style: AppTextStyles.linkAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable field label ─────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.fieldLabel);
  }
}

// ── Reusable text input field ────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AppTextStyles.fieldInput,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.fieldInput.copyWith(color: AppColors.light),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}

// ── Google coloured icon (drawn manually, no image asset needed) ─────────────
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    void sector(double start, double sweep, Color color) {
      final paint = Paint()..color = color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(s / 2, s / 2), radius: s / 2),
        start,
        sweep,
        true,
        paint,
      );
    }

    sector(-0.52, 1.57, const Color(0xFF4285F4));
    sector(1.05, 1.57, const Color(0xFF34A853));
    sector(2.62, 1.57, const Color(0xFFFBBC05));
    sector(-2.10, 1.57, const Color(0xFFEA4335));

    // white center hole
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

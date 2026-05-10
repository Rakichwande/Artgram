import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final result = await context.read<AuthService>().signUp(email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } else {
      setState(() => _error = result.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final accent   = isDark ? AppColors.roseDark    : AppColors.rose;
    final midColor = isDark ? AppColors.darkTextMid : AppColors.lightTextMid;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightSurface,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 4, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accent, AppColors.roseSoft, AppColors.roseLight]),
            )),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.chevron_left, size: 28,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      const SizedBox(height: 20),
                      Text('ArtGram', style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 12),
                      Text('Join the\ncommunity.',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text('Create your free artist account', style: TextStyle(color: midColor, fontSize: 13)),
                      const SizedBox(height: 32),

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _label(midColor, 'EMAIL'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(hintText: 'your@email.com'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      _label(midColor, 'PASSWORD'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'At least 6 characters',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: midColor),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      _label(midColor, 'CONFIRM PASSWORD'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: true,
                        onFieldSubmitted: (_) => _register(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(hintText: '••••••••'),
                        validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Create Account'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: midColor, fontSize: 12),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(text: 'Sign in', style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(Color color, String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: color));
  }
}

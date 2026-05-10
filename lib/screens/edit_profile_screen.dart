import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth         = AuthService();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl      = TextEditingController();
  bool _saving        = false;
  String? _success;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current values
    _usernameCtrl.text = _auth.currentUserEmail.split('@').first;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _saving = true; _success = null; });
    // Phase 2: this will call PATCH /users/{id} on FastAPI
    // For now simulate a save with a short delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() { _saving = false; _success = 'Profile updated successfully!'; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? AppColors.darkBackground  : AppColors.lightSurface;
    final accent      = isDark ? AppColors.roseDark        : AppColors.rose;
    final midColor    = isDark ? AppColors.darkTextMid     : AppColors.lightTextMid;
    final borderColor = isDark ? AppColors.darkBorder      : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 18, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 26, color: textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text('Edit Profile',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                        color: textPrimary)),
                  ),
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: Text('Save',
                      style: TextStyle(color: accent, fontWeight: FontWeight.w700,
                        fontSize: 15)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: Column(
                  children: [
                    // Success banner
                    if (_success != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text(_success!,
                            style: const TextStyle(color: AppColors.success, fontSize: 13)),
                        ]),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.roseLight,
                          child: Text(_auth.currentUserInitials,
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                              color: accent)),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: accent, shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                              size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Change photo',
                      style: TextStyle(fontSize: 13, color: accent,
                        fontWeight: FontWeight.w500)),

                    const SizedBox(height: 32),

                    // Username field
                    _fieldLabel('USERNAME', midColor),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameCtrl,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Your username',
                        prefixIcon: Icon(Icons.person_outline, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email (read only)
                    _fieldLabel('EMAIL', midColor),
                    const SizedBox(height: 8),
                    TextField(
                      enabled: false,
                      controller: TextEditingController(
                        text: _auth.currentUserEmail),
                      style: TextStyle(color: midColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBorder.withOpacity(0.3)
                            : AppColors.lightBorder.withOpacity(0.5),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email cannot be changed here',
                        style: TextStyle(fontSize: 11, color: midColor)),
                    ),
                    const SizedBox(height: 16),

                    // Bio field
                    _fieldLabel('BIO', midColor),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioCtrl,
                      maxLines: 3,
                      maxLength: 150,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Tell the world about your art...',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(height: 18, width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phase 2 note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accent.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Full profile editing with persistent storage will be '
                              'available in Phase 2 when FastAPI backend is complete.',
                              style: TextStyle(fontSize: 12, color: midColor, height: 1.5),
                            ),
                          ),
                        ],
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

  Widget _fieldLabel(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
          letterSpacing: 0.8, color: color)),
    );
  }
}

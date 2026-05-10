import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../repositories/post_repository.dart';
import '../theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onUploadSuccess;
  const UploadScreen({super.key, this.isTab = false, this.onUploadSuccess});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _captionCtrl = TextEditingController();
  final _picker      = ImagePicker();
  final _authRepo    = AuthRepository();
  final _postRepo    = PostRepository();

  File?  _image;
  bool   _uploading  = false;
  String? _error;
  String? _success;

  // Tags — keys match Firestore tag values exactly
  final List<Map<String, String>> _tags = [
    {'label': 'Painting',     'tag': '#Painting'},
    {'label': 'Illustration', 'tag': '#Illustration'},
    {'label': 'Sketch',       'tag': '#Sketch'},
    {'label': 'Digital',      'tag': '#Digital'},
    {'label': 'Anime',        'tag': '#Anime'},
    {'label': 'Watercolour',  'tag': '#Watercolour'},
    {'label': 'Photography',  'tag': '#Photography'},
    {'label': '3D Art',       'tag': '#3DArt'},
  ];

  final Set<String> _selTags   = {'#Digital'};
  int    _visibility           = 0;
  final List<String> _visLabels = ['Public', 'Followers', 'Private'];

  @override
  void dispose() { _captionCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery, imageQuality: 85, maxWidth: 1080);
    if (picked != null) {
      setState(() { _image = File(picked.path); _error = null; _success = null; });
    }
  }

  Future<void> _upload() async {
    if (_image == null) { setState(() => _error = 'Please select an image first.'); return; }
    setState(() { _uploading = true; _error = null; _success = null; });

    final result = await _postRepo.createPost(
      imageFile:      _image!,
      caption:        _captionCtrl.text.trim(),
      userId:         _authRepo.currentUserId,
      username:       _authRepo.currentUserEmail.split('@').first,
      avatarInitials: _authRepo.currentUserInitials,
      tags:           _selTags.toList(),  // ← pass selected tags
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _uploading = false;
        _success   = 'Your artwork was posted!';
        _image     = null;
        _captionCtrl.clear();
      });
      widget.onUploadSuccess?.call();
    } else {
      setState(() { _uploading = false; _error = result.errorMessage; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final accent      = isDark ? AppColors.roseDark        : AppColors.rose;
    final midColor    = isDark ? AppColors.darkTextMid     : AppColors.lightTextMid;
    final bgColor     = isDark ? AppColors.darkBackground  : AppColors.lightSurface;
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
                  if (!widget.isTab) IconButton(
                    icon: Icon(Icons.chevron_left, size: 26, color: textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(child: Text('Upload Art',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary))),
                  TextButton(
                    onPressed: _uploading ? null : _upload,
                    child: Text('Post', style: TextStyle(
                      color: accent, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (_success != null) ...[
                      _Banner(text: _success!, isError: false),
                      const SizedBox(height: 16),
                    ],
                    if (_error != null) ...[
                      _Banner(text: _error!, isError: true),
                      const SizedBox(height: 16),
                    ],

                    // Image zone
                    GestureDetector(
                      onTap: _uploading ? null : _pickImage,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _image != null
                            ? Stack(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                                ),
                                Positioned(
                                  bottom: 12, right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                    child: const Text('Change',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                ),
                              ])
                            : Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.roseLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.roseSoft, width: 2),
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 52, color: accent),
                                  const SizedBox(height: 14),
                                  Text('Tap to select artwork',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accent)),
                                  const SizedBox(height: 6),
                                  Text('JPG, PNG, GIF, WebP · max 20 MB',
                                    style: TextStyle(fontSize: 11,
                                      color: isDark ? AppColors.darkTextLight : AppColors.roseSoft)),
                                ]),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploading ? null : _upload,
                        icon: _uploading
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload_outlined, size: 20),
                        label: Text(_uploading ? 'Uploading...' : 'Upload Artwork'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(child: Text('Uploaded to your FastAPI server',
                      style: TextStyle(fontSize: 11, color: midColor))),
                    const SizedBox(height: 20),

                    // Caption
                    _SectionLabel(label: 'CAPTION', color: midColor),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _captionCtrl,
                      maxLines: 3,
                      maxLength: 300,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(hintText: 'Describe your artwork...'),
                    ),
                    const SizedBox(height: 16),

                    // Tags — select at least one before posting
                    _SectionLabel(label: 'TAGS  (select at least one)', color: midColor),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _tags.map((t) {
                        final tag = t['tag']!;
                        final sel = _selTags.contains(tag);
                        return GestureDetector(
                          onTap: () => setState(() =>
                            sel ? _selTags.remove(tag) : _selTags.add(tag)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.roseLight : Colors.transparent,
                              border: Border.all(
                                color: sel ? AppColors.roseSoft : borderColor, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(t['label']!,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                                color: sel ? AppColors.rose : midColor)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Visibility
                    _SectionLabel(label: 'VISIBILITY', color: midColor),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(_visLabels.length, (i) {
                        final active = _visibility == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _visibility = i),
                            child: Container(
                              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: active ? textPrimary : borderColor, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(_visLabels[i], textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12,
                                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                  color: active ? textPrimary : midColor)),
                            ),
                          ),
                        );
                      }),
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

class _Banner extends StatelessWidget {
  final String text;
  final bool isError;
  const _Banner({required this.text, required this.isError});
  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});
  @override
  Widget build(BuildContext context) =>
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
        letterSpacing: 0.8, color: color));
}

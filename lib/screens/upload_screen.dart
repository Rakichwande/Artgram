import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _captionController = TextEditingController();

  // Tags
  final List<String> _tags = [
    '#Painting',
    '#Illustration',
    '#Sketch',
    '#Digital',
    '#Watercolour',
    '#Photography',
  ];
  final Set<String> _selectedTags = {'#Painting'};

  // Visibility
  final List<String> _visibility = ['Public', 'Followers', 'Private'];
  int _selectedVisibility = 0;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────
            _buildAppBar(context),
            const Divider(height: 1, color: AppColors.border),

            // ── Scrollable content ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Upload zone ──────────────────────────────────────
                    _buildUploadZone(),

                    const SizedBox(height: 20),

                    // ── Upload button ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_outlined, size: 18),
                        label: const Text('Upload Art'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.charcoal,
                          foregroundColor: AppColors.white,
                          textStyle: AppTextStyles.buttonPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Caption field ────────────────────────────────────
                    Text('CAPTION', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _captionController,
                      maxLines: 3,
                      style: AppTextStyles.fieldInput,
                      decoration: InputDecoration(
                        hintText: 'Write something about your piece...',
                        hintStyle:
                            AppTextStyles.fieldInput.copyWith(color: AppColors.light),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.rose,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAF9),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Tags ─────────────────────────────────────────────
                    Text('TAGS', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        final selected = _selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () => setState(() {
                            selected
                                ? _selectedTags.remove(tag)
                                : _selectedTags.add(tag);
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.roseLight
                                  : Colors.transparent,
                              border: Border.all(
                                color: selected
                                    ? AppColors.roseSoft
                                    : AppColors.border,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.tagChip.copyWith(
                                color: selected ? AppColors.rose : AppColors.mid,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ── Visibility toggle ─────────────────────────────────
                    Text('VISIBILITY', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(_visibility.length, (i) {
                        final active = _selectedVisibility == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedVisibility = i),
                            child: Container(
                              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: active
                                      ? AppColors.charcoal
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _visibility[i],
                                textAlign: TextAlign.center,
                                style: active
                                    ? AppTextStyles.visibilityActive
                                    : AppTextStyles.visibilityInactive,
                              ),
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

  // ── App bar with back button and Post action ──────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            color: AppColors.charcoal,
            onPressed: () => Navigator.pop(context),
          ),
          Text('Upload Art', style: AppTextStyles.screenTitle),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Text('Post', style: AppTextStyles.postRose),
          ),
        ],
      ),
    );
  }

  // ── Dashed upload zone ────────────────────────────────────────────────────
  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: () {},
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.roseLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.upload_file_outlined,
                  size: 40,
                  color: AppColors.rose,
                ),
                const SizedBox(height: 12),
                Text('Tap to select artwork', style: AppTextStyles.uploadZoneText),
                const SizedBox(height: 4),
                Text('JPG, PNG, GIF · up to 20 MB', style: AppTextStyles.uploadZoneSub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dashed border painter ─────────────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    const radius = 20.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(radius),
    );

    // Approximate dashed border using path metrics
    final path = Path()..addRRect(rect);
    final metricsList = path.computeMetrics().toList();

    for (final metric in metricsList) {
  double distance = 0;
  while (distance < metric.length) {
    final start = distance;
    final end = (distance + dashWidth).clamp(0.0, metric.length); // ← fix here
    canvas.drawPath(metric.extractPath(start, end), paint);
    distance += dashWidth + dashSpace;
  }
}
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

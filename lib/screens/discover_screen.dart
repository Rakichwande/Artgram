import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Digital Art',  'icon': Icons.computer_outlined,         'color': Color(0xFF5C8DB3)},
    {'label': 'Anime',        'icon': Icons.auto_awesome_outlined,      'color': Color(0xFFC97B6E)},
    {'label': 'Sketches',     'icon': Icons.edit_outlined,             'color': Color(0xFF6B8F71)},
    {'label': 'Paintings',    'icon': Icons.brush_outlined,            'color': Color(0xFFB3905C)},
    {'label': '3D Art',       'icon': Icons.view_in_ar_outlined,       'color': Color(0xFF7B6EB3)},
    {'label': 'Photography',  'icon': Icons.camera_alt_outlined,       'color': Color(0xFF5CB3A8)},
    {'label': 'Watercolour',  'icon': Icons.water_drop_outlined,       'color': Color(0xFF8DB35C)},
    {'label': 'Illustrations','icon': Icons.palette_outlined,          'color': Color(0xFFB35C8D)},
  ];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgColor  = isDark ? AppColors.darkBackground  : AppColors.lightBackground;
    final midColor = isDark ? AppColors.darkTextMid     : AppColors.lightTextMid;
    final borderColor = isDark ? AppColors.darkBorder   : AppColors.lightBorder;
    final cardColor   = isDark ? AppColors.darkCard     : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discover', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                controller: _searchCtrl,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search artists, styles, tags...',
                  prefixIcon: Icon(Icons.search, color: midColor, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: midColor, size: 18),
                          onPressed: () => setState(() => _searchCtrl.clear()),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              Text('Browse by Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
              const SizedBox(height: 12),

              // Category grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: (cat['color'] as Color).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(cat['label'] as String,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

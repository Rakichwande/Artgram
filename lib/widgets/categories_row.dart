import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoriesRow extends StatelessWidget {
  final ValueChanged<String> onCategorySelected;
  final String selectedTag;

  const CategoriesRow({
    super.key,
    required this.onCategorySelected,
    required this.selectedTag,
  });

  static const List<Map<String, dynamic>> cats = [
    {'label': 'All',         'tag': 'All',         'icon': Icons.grid_view_rounded},
    {'label': 'Digital Art', 'tag': '#Digital',     'icon': Icons.computer_outlined},
    {'label': 'Anime',       'tag': '#Anime',       'icon': Icons.auto_awesome_outlined},
    {'label': 'Illustration','tag': '#Illustration','icon': Icons.palette_outlined},
    {'label': 'Sketches',    'tag': '#Sketch',      'icon': Icons.edit_outlined},
    {'label': 'Paintings',   'tag': '#Painting',    'icon': Icons.brush_outlined},
    {'label': '3D Art',      'tag': '#3DArt',       'icon': Icons.view_in_ar_outlined},
    {'label': 'Watercolour', 'tag': '#Watercolour', 'icon': Icons.water_drop_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final accent   = isDark ? AppColors.roseDark    : AppColors.rose;
    final bgColor  = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final midColor = isDark ? AppColors.darkTextMid : AppColors.lightTextMid;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: cats.map((cat) {
            final active = selectedTag == cat['tag'];
            return GestureDetector(
              onTap: () => onCategorySelected(cat['tag'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? accent
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 1.5,
                  ),
                ),
                child: Row(children: [
                  Icon(cat['icon'] as IconData,
                    size: 15,
                    color: active ? Colors.white : midColor),
                  const SizedBox(width: 6),
                  Text(cat['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? Colors.white : midColor,
                    )),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

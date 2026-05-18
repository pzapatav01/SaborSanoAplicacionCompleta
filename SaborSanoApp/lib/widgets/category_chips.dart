import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Chips de categorías en scroll horizontal. Una categoría puede estar seleccionada.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    this.selectedId,
    this.onSelected,
  });

  final List<CategoryItem> categories;
  final String? selectedId;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = categories[i];
          final isSelected = item.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected?.call(item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.chipSelectedBg : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.showSparkle && isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.auto_awesome, size: 14, color: AppTheme.accentLime),
                    ),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryItem {
  const CategoryItem({required this.id, required this.label, this.showSparkle = false});
  final String id;
  final String label;
  final bool showSparkle;
}

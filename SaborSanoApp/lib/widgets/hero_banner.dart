import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Banner hero reutilizable: imagen, título, subtítulo, CTA y indicadores de carrusel.
class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.highlightText,
    this.ctaLabel = 'Comprar ahora',
    this.onCtaTap,
    this.imageWidget,
    this.currentPage = 0,
    this.pageCount = 4,
    this.useFullWidth = false,
  });

  final String title;
  final String? subtitle;
  final String? highlightText;
  final String ctaLabel;
  final VoidCallback? onCtaTap;
  final Widget? imageWidget;
  final int currentPage;
  final int pageCount;
  /// Si true, el banner ocupa el 100% del ancho (sin márgenes laterales).
  final bool useFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: useFullWidth ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
      width: useFullWidth ? double.infinity : null,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: useFullWidth ? BorderRadius.zero : BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: useFullWidth ? BorderRadius.zero : BorderRadius.circular(16),
        child: Stack(
          children: [
            // Imagen o placeholder a la derecha
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 160,
              child: imageWidget ??
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          AppTheme.accentLime.withOpacity(0.15),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.image_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
            ),
            // Contenido izquierdo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 24, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null || highlightText != null) ...[
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        children: [
                          if (subtitle != null) TextSpan(text: '$subtitle '),
                          if (highlightText != null)
                            TextSpan(
                              text: highlightText,
                              style: const TextStyle(color: AppTheme.accentLime, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Material(
                    color: AppTheme.accentLime,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: onCtaTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(ctaLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Indicadores del carrusel
            Positioned(
              left: 20,
              bottom: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(pageCount, (i) {
                  final isActive = i == currentPage;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.accentLime : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

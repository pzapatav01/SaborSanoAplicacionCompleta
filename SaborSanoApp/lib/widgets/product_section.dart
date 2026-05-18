import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'product_card.dart';

/// Ancho fijo de cada tarjeta en las listas horizontales.
const double kProductCardWidth = 168;

/// Sección de productos con título, lista horizontal deslizable y botones de flecha.
class ProductSection extends StatefulWidget {
  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.onProductTap,
  });

  final String title;
  final List<Map<String, String>> products;
  /// Recibe el producto tocado: id, name, price.
  final void Function(Map<String, String> product)? onProductTap;

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(bool forward) {
    const step = kProductCardWidth + 12;
    final offset = _scrollController.offset + (forward ? step : -step);
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.products.length,
                itemBuilder: (context, i) {
                  final p = widget.products[i];
                  final imageUrl = p['imageUrl'];
                  return Padding(
                    padding: EdgeInsets.only(right: i < widget.products.length - 1 ? 12 : 0),
                    child: SizedBox(
                      width: kProductCardWidth,
                      child: ProductCard(
                        name: p['name']!,
                        price: p['price'],
                        imageWidget: (imageUrl != null && imageUrl.isNotEmpty)
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppTheme.surfaceLight,
                                  child: Icon(Icons.image_not_supported_outlined,
                                      color: AppTheme.textSecondary, size: 40),
                                ),
                              )
                            : null,
                        onTap: () => widget.onProductTap?.call(p),
                      ),
                    ),
                  );
                },
              ),
              // Flecha izquierda sobre las cards
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _SectionArrowButton(
                    icon: Icons.chevron_left,
                    onTap: () => _scroll(false),
                  ),
                ),
              ),
              // Flecha derecha sobre las cards
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _SectionArrowButton(
                    icon: Icons.chevron_right,
                    onTap: () => _scroll(true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionArrowButton extends StatelessWidget {
  const _SectionArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 26, color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}

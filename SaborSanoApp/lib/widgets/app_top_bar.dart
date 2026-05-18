import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra superior reutilizable: menú hamburguesa (izq), búsqueda [+ filtro opcional], icono carrito (der).
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.searchHint = 'Explorar productos',
    this.showSearchBar = true,
    this.showFilterButton = true,
    this.onSearchTap,
    this.onCartTap,
    this.onMenuTap,
    this.onFilterTap,
  });

  final String searchHint;
  /// Si false, no se muestra la fila de búsqueda (solo menú, título y carrito).
  final bool showSearchBar;
  /// Si false, no se muestra el botón de filtro (solo búsqueda).
  final bool showFilterButton;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  /// Callback al tocar el ícono de menú hamburguesa.
  final VoidCallback? onMenuTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Menú hamburguesa
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                // Título centrado
                Expanded(
                  child: Center(
                    child: Text(
                      'Sabor Sano',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Carrito
                IconButton(
                  onPressed: onCartTap,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            if (showSearchBar) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onSearchTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              searchHint,
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showFilterButton) ...[
                    const SizedBox(width: 10),
                    Material(
                      color: AppTheme.accentLime,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: onFilterTap,
                        borderRadius: BorderRadius.circular(12),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.tune, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

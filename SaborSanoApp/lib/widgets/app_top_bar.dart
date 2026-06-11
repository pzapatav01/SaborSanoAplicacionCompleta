import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra superior: menú hamburguesa, título y carrito.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.onCartTap,
    this.onMenuTap,
  });

  final VoidCallback? onCartTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Expanded(
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
            IconButton(
              onPressed: onCartTap,
              icon: const Icon(Icons.shopping_cart_outlined),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

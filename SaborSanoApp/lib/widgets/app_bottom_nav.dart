import 'package:flutter/material.dart';

import '../services/client_session.dart';
import '../theme/app_theme.dart';

/// Ítem reutilizable del bottom nav: icono + label, con estado activo (fondo verde lima).
class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.accentLime : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra inferior: Inicio, Carrito y Perfil (con sesión) o Login (sin sesión).
class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  State<AppBottomNavBar> createState() => AppBottomNavBarState();
}

class AppBottomNavBarState extends State<AppBottomNavBar> {
  bool _hasSession = false;
  bool _loadingSession = true;

  @override
  void initState() {
    super.initState();
    refreshSession();
  }

  Future<void> refreshSession() async {
    final profile = await ClientSession.get();
    if (!mounted) return;
    setState(() {
      _hasSession =
          profile != null && profile.idCliente.trim().isNotEmpty;
      _loadingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final thirdLabel = _hasSession ? 'Perfil' : 'Login';
    final thirdIcon =
        _hasSession ? Icons.person_outline : Icons.login_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              NavButton(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isActive: widget.currentIndex == 0,
                onTap: () => widget.onTap?.call(0),
              ),
              NavButton(
                icon: Icons.shopping_cart_outlined,
                label: 'Carrito',
                isActive: widget.currentIndex == 1,
                onTap: () => widget.onTap?.call(1),
              ),
              NavButton(
                icon: thirdIcon,
                label: _loadingSession ? '...' : thirdLabel,
                isActive: widget.currentIndex == 2,
                onTap: () => widget.onTap?.call(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

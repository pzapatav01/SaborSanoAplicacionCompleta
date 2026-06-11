import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/categories_repository.dart';

/// Opción del menú lateral (categorías).
class MenuCategoryItem {
  const MenuCategoryItem({required this.id, required this.label, this.icon});
  final String id;
  final String label;
  final IconData? icon;
}

/// Layout principal reutilizable: barra superior con menú hamburguesa, cuerpo y opcionalmente navegación inferior.
/// Usa [showBottomNav] en false para pantallas como la Home (solo header, sin bottom nav).
class MainLayout extends StatefulWidget {
  const MainLayout({
    super.key,
    required this.body,
    this.showBottomNav = true,
    this.currentNavIndex = 0,
    this.onNavTap,
    this.onCartTap,
    this.menuCategories = const [],
    this.onMenuCategoryTap,
  });

  final Widget body;
  final bool showBottomNav;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onCartTap;
  final List<MenuCategoryItem> menuCategories;
  final ValueChanged<String>? onMenuCategoryTap;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AppBottomNavBarState> _bottomNavKey =
      GlobalKey<AppBottomNavBarState>();
  List<MenuCategoryItem> _dynamicCategories = const [];
  bool _loadingCategories = false;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    if (widget.menuCategories.isEmpty) {
      _loadCategories();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bottomNavKey.currentState?.refreshSession();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });
    try {
      final categories = await CategoriesRepository.getAll();
      if (!mounted) return;
      setState(() {
        _dynamicCategories = categories
            .map((c) => MenuCategoryItem(
                  id: c.id,
                  label: c.name,
                  icon: _iconForCategoryIdOrName(c.id, c.name),
                ))
            .toList();
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = 'No se pudieron cargar las categorías.';
        _loadingCategories = false;
      });
    }
  }

  IconData _iconForCategoryIdOrName(String id, String name) {
    final key = (id.isNotEmpty ? id : name).toLowerCase();
    if (key.contains('cosmet') || key == 'cosmeticos') {
      return Icons.spa_rounded;
    }
    if (key.contains('alimen') || key == 'alimentos') {
      return Icons.restaurant_rounded;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final void Function() openDrawer = () {
      _scaffoldKey.currentState?.openDrawer();
    };
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.surfaceLight,
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          AppTopBar(
            onCartTap: widget.onCartTap,
            onMenuTap: openDrawer,
          ),
          Expanded(child: widget.body),
          if (widget.showBottomNav)
            AppBottomNavBar(
              key: _bottomNavKey,
              currentIndex: widget.currentNavIndex,
              onTap: widget.onNavTap,
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // Inicio e Información siempre fijos al inicio.
    final baseItems = const [
      MenuCategoryItem(
        id: 'inicio',
        label: 'Inicio',
        icon: Icons.home_rounded,
      ),
      MenuCategoryItem(
        id: 'informacion',
        label: 'Información',
        icon: Icons.info_outline_rounded,
      ),
    ];

    final categories = widget.menuCategories.isNotEmpty
        ? widget.menuCategories
        : [
            ...baseItems,
            ..._dynamicCategories,
          ];

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'SaborSano',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentLimeDark,
                    ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, i) {
                  final item = categories[i];
                  return ListTile(
                    leading: Icon(item.icon ?? Icons.category_outlined, color: AppTheme.textSecondary, size: 22),
                    title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onMenuCategoryTap?.call(item.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

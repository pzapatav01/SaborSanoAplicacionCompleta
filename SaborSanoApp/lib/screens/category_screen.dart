import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_section.dart';
import '../theme/app_theme.dart';
import '../services/products_repository.dart';
import '../services/product_model.dart';
import '../utils/bottom_nav_actions.dart';
import 'info_web_screen.dart';

/// Pantalla que se muestra al elegir una categoría: chips y productos por secciones con scroll horizontal.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  final String? categoryId;
  final String? categoryName;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _selectedCategoryId;
  String? _selectedSearchText;
  List<Product> _especial = const [];
  List<Product> _vendidos = const [];
  List<Product> _nuevos = const [];
  bool _loading = true;
  String? _error;
  List<CategoryItem> _categories = const [];

  @override
  void initState() {
    super.initState();
    _buildCategoryChips();
    _loadProducts();
  }

  void _buildCategoryChips() {
    final rawKey = (widget.categoryId ?? widget.categoryName ?? '').toLowerCase();
    String key;
    if (rawKey.contains('alimen')) {
      key = 'alimentos';
    } else if (rawKey.contains('cosmet')) {
      key = 'cosmeticos';
    } else {
      key = 'general';
    }

    List<CategoryItem> items;
    if (key == 'alimentos') {
      items = const [
        CategoryItem(id: 'vegano', label: 'Vegano'),
        CategoryItem(id: 'sano', label: 'Sano'),
        CategoryItem(id: 'verduras', label: 'Verduras'),
      ];
    } else if (key == 'cosmeticos') {
      items = const [
        CategoryItem(id: 'natural', label: 'Natural'),
        CategoryItem(id: 'organico', label: 'Orgánico'),
        CategoryItem(id: 'facial', label: 'Cuidado facial'),
      ];
    } else {
      items = const [
        CategoryItem(id: 'ofertas', label: 'Ofertas'),
        CategoryItem(id: 'nuevo', label: 'Nuevo'),
        CategoryItem(id: 'popular', label: 'Popular'),
      ];
    }

    _categories = items;
    if (items.isNotEmpty) {
      _selectedCategoryId = items.first.id;
      _selectedSearchText = items.first.label;
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items =
          await ProductsRepository.getByCategory(_selectedSearchText);
      if (!mounted) return;
      setState(() {
        _especial = items;
        _vendidos = List<Product>.from(items.reversed);
        _nuevos = items.take(6).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los productos de esta categoría.';
        _loading = false;
      });
    }
  }

  List<Map<String, String>> _toProductMaps(List<Product> items) {
    return items
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'price': p.formattedPrice,
              'imageUrl': p.imageUrl ?? '',
            })
        .toList();
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        Navigator.of(context).pushNamed('/cart');
        break;
      case 2:
        BottomNavActions.goToProfileOrLogin(context);
        break;
    }
  }

  void _onMenuCategoryTap(BuildContext context, String categoryId) {
    switch (categoryId) {
      case 'inicio':
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 'informacion':
        Navigator.of(context).pushNamed('/info', arguments: kInfoUrl);
        break;
      case 'cosmeticos':
      case 'alimentos':
        Navigator.of(context).pushNamed('/category', arguments: categoryId);
        break;
      default:
        Navigator.of(context).pushNamed('/category', arguments: categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      showBottomNav: true,
      currentNavIndex: 0,
      onNavTap: _onNavTap,
      onCartTap: () => Navigator.of(context).pushNamed('/cart'),
      onMenuCategoryTap: (id) => _onMenuCategoryTap(context, id),
      body: Scrollbar(
        thumbVisibility: true,
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          color: AppTheme.accentLime,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const SizedBox(height: 8),
            CategoryChips(
              categories: _categories,
              selectedId: _selectedCategoryId,
              onSelected: (id) {
                final chip = _categories.firstWhere(
                  (c) => c.id == id,
                  orElse: () => const CategoryItem(id: 'all', label: 'Todos'),
                );
                setState(() {
                  _selectedCategoryId = id;
                  _selectedSearchText = chip.label;
                });
                _loadProducts();
              },
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: AppTheme.accentLime,
                  ),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadProducts,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else ...[
              ProductSection(
                title: 'Especial para ti',
                products: _toProductMaps(_especial),
                onProductTap: (product) => Navigator.of(context)
                    .pushNamed('/product', arguments: product),
              ),
              const SizedBox(height: 24),
              ProductSection(
                title: 'Más vendidos',
                products: _toProductMaps(_vendidos),
                onProductTap: (product) => Navigator.of(context)
                    .pushNamed('/product', arguments: product),
              ),
              const SizedBox(height: 24),
              ProductSection(
                title: 'Nuevos',
                products: _toProductMaps(_nuevos),
                onProductTap: (product) => Navigator.of(context)
                    .pushNamed('/product', arguments: product),
              ),
            ],
            const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

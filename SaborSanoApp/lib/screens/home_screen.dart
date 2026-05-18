import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../widgets/product_section.dart';
import '../theme/app_theme.dart';
import '../services/products_repository.dart';
import '../services/product_model.dart';
import 'info_web_screen.dart';

/// Pantalla de inicio: header (sin bottom nav), bienvenida y productos por secciones con scroll horizontal.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _especial = const [];
  List<Product> _vendidos = const [];
  List<Product> _nuevos = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await ProductsRepository.getHomeProducts();
      if (!mounted) return;
      setState(() {
        _especial = products;
        _vendidos = List<Product>.from(products.reversed);
        _nuevos = products.take(6).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los productos.';
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Bienvenida
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Bienvenido a SaborSano',
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Explora categorías desde el menú para ver productos, recetas y más.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
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
                  // Sección: Especial para ti
                  ProductSection(
                    title: 'Especial para ti',
                    products: _toProductMaps(_especial),
                    onProductTap: (product) => Navigator.of(context)
                        .pushNamed('/product', arguments: product),
                  ),
                  const SizedBox(height: 24),
                  // Sección: Más vendidos
                  ProductSection(
                    title: 'Más vendidos',
                    products: _toProductMaps(_vendidos),
                    onProductTap: (product) => Navigator.of(context)
                        .pushNamed('/product', arguments: product),
                  ),
                  const SizedBox(height: 24),
                  // Sección: Nuevos
                  ProductSection(
                    title: 'Nuevos',
                    products: _toProductMaps(_nuevos),
                    onProductTap: (product) => Navigator.of(context)
                        .pushNamed('/product', arguments: product),
                  ),
                  const SizedBox(height: 24),
                ],
                // Pie de página en home
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    color: AppTheme.surfaceCard,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sabor Sano',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cuidamos de ti con productos naturales y un estilo de vida más consciente.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
      showBottomNav: false,
    );
  }
}

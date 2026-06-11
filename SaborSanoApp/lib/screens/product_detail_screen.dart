import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/cart_storage.dart';
import '../services/product_model.dart';
import '../services/products_repository.dart';
import '../services/reviews_repository.dart';
import '../services/client_session.dart';
import '../layouts/main_layout.dart';
import '../utils/bottom_nav_actions.dart';
import 'info_web_screen.dart';

/// Pantalla de detalle del producto: datos, cantidad y agregar al carrito (persistido local).
/// Muestra bottom nav; solo Home no lo muestra.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    this.productId,
    this.productName,
    this.productPrice,
    this.productImageUrl,
  });

  final String? productId;
  final String? productName;
  final String? productPrice;
  final String? productImageUrl;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAdding = false;
  bool _loading = true;
  String? _error;
  Product? _product;
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  List<Review> _reviews = const [];
  bool _loadingReviews = false;

  String get _id => (_product?.id ?? widget.productId ?? '').trim();
  String get _name =>
      _product?.name ?? widget.productName?.trim() ?? 'Producto';
  String get _price =>
      _product?.formattedPrice ?? widget.productPrice?.trim() ?? '\$0.00';

  String? get _imageUrl {
    final fromApi = _product?.imageUrl?.trim();
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    final fromNav = widget.productImageUrl?.trim();
    if (fromNav != null && fromNav.isNotEmpty) return fromNav;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final id = widget.productId?.trim();
    if (id == null || id.isEmpty) {
      // No hay id: usamos solo los datos pasados por argumentos.
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = await ProductsRepository.getProductById(id);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
      });
      await _loadReviews();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el producto.';
        _loading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    final id = _id;
    if (id.isEmpty) return;
    setState(() => _loadingReviews = true);
    try {
      final list = await ReviewsRepository.getByProduct(id);
      if (!mounted) return;
      setState(() {
        _reviews = list;
        _loadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingReviews = false);
    }
  }

  Future<void> _addToCart() async {
    if (_id.isEmpty) {
      _showSnack('Producto no válido.');
      return;
    }
    if (_quantity < 1) {
      _showSnack('La cantidad debe ser al menos 1.');
      return;
    }
    setState(() => _isAdding = true);
    try {
      final cartItem = _product?.toCartItem(quantity: _quantity) ??
          CartItem(
            id: _id,
            name: _name,
            price: _price,
            quantity: _quantity,
          );
      await CartStorage.addItem(cartItem);
      if (!mounted) return;
      _showSnack('Añadido al carrito');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error al añadir al carrito');
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accentLimeDark,
      ),
    );
  }

  Future<bool> _ensureClientSession() async {
    final current = await ClientSession.get();
    if (current != null && current.idCliente.trim().isNotEmpty) {
      return true;
    }
    // Ir a registro y volver.
    final result = await Navigator.of(context).pushNamed('/register');
    final after = await ClientSession.get();
    return after != null && after.idCliente.trim().isNotEmpty;
  }

  Future<void> _onSubmitReview() async {
    if (_selectedRating == 0 || _reviewController.text.trim().isEmpty) {
      _showSnack('Selecciona una calificación y escribe tu reseña.');
      return;
    }
    if (_id.isEmpty) {
      _showSnack('Producto no válido para reseñas.');
      return;
    }

    final hasClient = await _ensureClientSession();
    if (!hasClient) {
      _showSnack('Debes registrar tus datos para dejar una reseña.');
      return;
    }

    try {
      await ReviewsRepository.createReview(
        productId: _id,
        rating: _selectedRating,
        comment: _reviewController.text.trim(),
      );
      _showSnack('Gracias por tu reseña.');
      _reviewController.clear();
      setState(() {
        _selectedRating = 0;
      });
      await _loadReviews();
    } catch (e) {
      _showSnack(
          'No se pudo enviar la reseña. Intenta nuevamente más tarde.');
    }
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 40),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Detalle',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              // Imagen del producto (desde backend) con fallback.
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageUrl != null
                    ? Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.accentLime,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 80,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: AppTheme.textSecondary,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                _name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _price,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentLimeDark,
                    ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: AppTheme.accentLime,
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    'Cantidad',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isAdding ? null : _addToCart,
                icon: _isAdding
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart_outlined, size: 22),
                label: Text(_isAdding ? 'Añadiendo...' : 'Agregar al carrito'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentLime,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Reseñas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                color: AppTheme.surfaceCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escribe una reseña',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          final isFilled = _selectedRating >= starIndex;
                          return IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isFilled
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: isFilled
                                  ? AppTheme.accentLimeDark
                                  : AppTheme.textSecondary,
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() => _selectedRating = starIndex);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reviewController,
                        maxLines: 3,
                        maxLength: 250,
                        decoration: InputDecoration(
                          hintText: 'Cuéntanos qué te pareció este producto...',
                          filled: true,
                          fillColor: AppTheme.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _onSubmitReview,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.accentLime,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Enviar reseña'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Lo que dicen otros clientes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              if (_loadingReviews)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: AppTheme.accentLime,
                    ),
                  ),
                )
              else if (_reviews.isEmpty)
                Text(
                  'Aún no hay reseñas para este producto.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                )
              else ...[
                for (final r in _reviews)
                  _ReviewTile(
                    name: r.clientName,
                    rating: r.rating,
                    date: '', // Podrías mapear fecha si la agregas al modelo.
                    comment: r.comment,
                  ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  final String name;
  final int rating;
  final String date;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              final isFilled = rating > index;
              return Icon(
                isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                size: 18,
                color: isFilled
                    ? AppTheme.accentLimeDark
                    : AppTheme.textSecondary,
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceLight,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppTheme.textPrimary, size: 24),
        ),
      ),
    );
  }
}

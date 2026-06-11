import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../theme/app_theme.dart';
import '../services/cart_storage.dart';
import '../services/orders_repository.dart';
import '../services/client_session.dart';
import '../utils/bottom_nav_actions.dart';
import 'info_web_screen.dart';

/// Pantalla del carrito: lee y elimina ítems desde persistencia local (CartStorage).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _items = [];
  bool _loading = true;
  String? _error;
  bool _isFinishing = false;

  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await CartStorage.getCart();
      if (mounted) setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Error al cargar el carrito';
        _loading = false;
      });
    }
  }

  Future<void> _removeItem(String id) async {
    await CartStorage.removeItem(id);
    await _loadCart();
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        break;
      case 2:
        BottomNavActions.goToProfileOrLogin(context);
        break;
    }
  }

  Future<void> _finishPurchase() async {
    final hasClient = await _ensureClientProfile();
    if (!hasClient) return;

    setState(() => _isFinishing = true);

    final subtotal = _items.fold<double>(0, (sum, i) {
      final p = double.tryParse(i.price.replaceFirst('\$', '').trim()) ?? 0;
      return sum + p * i.quantity;
    });

    try {
      final orderId = await OrdersRepository.createOrderFromCart(_items);
      await CartStorage.clear();
      if (!mounted) return;

      await Navigator.of(context).pushNamed(
        '/checkout-payment',
        arguments: {
          'orderId': orderId,
          'total': subtotal,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', 'Error: '),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  /// Verifica si hay un cliente registrado localmente.
  /// Si no lo hay, navega a la pantalla de registro y vuelve luego al carrito.
  Future<bool> _ensureClientProfile() async {
    final current = await ClientSession.get();
    if (current != null && current.idCliente.isNotEmpty) {
      return true;
    }

    // No hay sesión: ir al formulario de registro.
    final result = await Navigator.of(context).pushNamed('/register');

    // Si el usuario completó el registro (pop(true)), o simplemente
    // hay ahora un perfil válido, permitimos continuar.
    final after = await ClientSession.get();
    if (after != null && after.idCliente.isNotEmpty) {
      return true;
    }

    // No hay contexto válido: si no hay ninguna ruta anterior,
    // mandamos al inicio como fallback.
    if (!Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    return false;
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
    final subtotal = _items.fold<double>(0, (sum, i) {
      final p = double.tryParse(i.price.replaceFirst('\$', '').trim()) ?? 0;
      return sum + p * i.quantity;
    });
    final total = subtotal;

    return MainLayout(
      showBottomNav: true,
      currentNavIndex: 1,
      onNavTap: _onNavTap,
      onCartTap: () {},
      onMenuCategoryTap: (id) => _onMenuCategoryTap(context, id),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
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
                Expanded(
                  child: Text(
                    'Tu carrito',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentLime))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _loadCart,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.textSecondary),
                                const SizedBox(height: 16),
                                Text(
                                  'Tu carrito está vacío',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: 16,
                            ),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final item = _items[i];
                              return _CartItemTile(
                                name: item.name,
                                price: item.price,
                                quantity: item.quantity,
                                imageUrl: item.imageUrl,
                                onRemove: () => _removeItem(item.id),
                              );
                            },
                          ),
                        ),
          ),
          if (!_loading && _items.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentLimeDark,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isFinishing ? null : _finishPurchase,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentLime,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isFinishing ? 'Creando pedido...' : 'Continuar al pago',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.name,
    required this.price,
    required this.quantity,
    required this.onRemove,
    this.imageUrl,
  });

  final String name;
  final String price;
  final int quantity;
  final VoidCallback onRemove;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 72,
              height: 72,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surfaceLight,
                        child: Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.surfaceLight,
                      child: Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.accentLimeDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cantidad: $quantity',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

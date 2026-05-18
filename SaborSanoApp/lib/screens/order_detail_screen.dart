import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/orders_repository.dart';

/// Pantalla de detalle de un pedido: consulta a la API y muestra
/// cliente, productos, método de pago y estado de envío.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderDetailData? _order;
  bool _loading = true;
  String? _error;

  static String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await OrdersRepository.getOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Detalle del pedido'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(foregroundColor: AppTheme.textPrimary),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentLime),
      );
    }
    if (_error != null || _order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'No se pudo cargar el pedido.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _load,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryCard(
              id: order.id,
              date: _formatDate(order.createdAt),
              estado: order.estado,
              clienteNombre: order.clienteNombre,
              clienteEmail: order.clienteEmail,
              total: order.total,
              paymentLabel: order.metodoPago,
              estadoEnvio: order.estadoEnvio,
              itemCount: order.itemCount,
            ),
            const SizedBox(height: 20),
            Text(
              'Productos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            ...order.items.map(
              (item) => _OrderItemTile(
                name: item.name,
                price: item.price,
                quantity: item.quantity,
                imageUrl: item.imageUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.id,
    required this.date,
    required this.estado,
    required this.clienteNombre,
    required this.clienteEmail,
    required this.total,
    this.paymentLabel,
    this.estadoEnvio,
    required this.itemCount,
  });

  final String id;
  final String date;
  final String estado;
  final String clienteNombre;
  final String clienteEmail;
  final double total;
  final String? paymentLabel;
  final String? estadoEnvio;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'Pedido', value: id),
          const SizedBox(height: 8),
          _Row(label: 'Fecha', value: date),
          const SizedBox(height: 8),
          _Row(label: 'Productos', value: '$itemCount'),
          const SizedBox(height: 8),
          _Row(label: 'Estado', value: estado),
          const SizedBox(height: 8),
          _Row(label: 'Cliente', value: clienteNombre),
          const SizedBox(height: 4),
          _Row(label: 'Email', value: clienteEmail),
          if (paymentLabel != null && paymentLabel!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(label: 'Pago', value: paymentLabel!),
          ],
          if (estadoEnvio != null && estadoEnvio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(label: 'Envío', value: estadoEnvio!),
          ],
          const Divider(height: 20),
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
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final String name;
  final String price;
  final int quantity;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final unitPrice = double.tryParse(price.replaceFirst('\$', '').trim()) ?? 0;
    final subtotal = unitPrice * quantity;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surfaceLight,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 26,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.surfaceLight,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 26,
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
                  '$price × $quantity',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.accentLimeDark,
            ),
          ),
        ],
      ),
    );
  }
}

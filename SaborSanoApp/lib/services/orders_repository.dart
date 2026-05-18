import 'api_client.dart';
import 'cart_storage.dart';
import 'client_session.dart';

/// Modelo de pedido para la app (ya normalizado desde el backend).
class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.total,
    this.paymentLabel,
  });

  final String id;
  final String createdAt;
  final List<CartItem> items;
  final double total;
  final String? paymentLabel;

  int get itemCount => items.fold<int>(0, (sum, i) => sum + i.quantity);
}

/// Repositorio de pedidos: crea pedidos y obtiene "mis pedidos" desde la API.
class OrdersRepository {
  OrdersRepository._();

  static final ApiClient _client = ApiClient();

  static const String _myOrdersPath = '/api/pedidos/mis-pedidos';
  static const String _createOrderPath = '/api/pedidos';
  static const String _myOrderDetailPath = '/api/pedidos/mis-pedidos';

  /// Obtiene la lista de pedidos del usuario autenticado mediante X-Client-ID.
  static Future<List<Order>> getOrders() async {
    final profile = await ClientSession.get();
    if (profile == null || profile.idCliente.trim().isEmpty) {
      throw Exception('No hay cliente autenticado');
    }

    final list = await _client.getJsonList(
      _myOrdersPath,
      headers: {'X-Client-ID': profile.idCliente},
    );

    return list
        .where((e) => e is Map<String, dynamic>)
        .map((e) => _orderFromApi(e as Map<String, dynamic>))
        .toList();
  }

  /// Envía el pedido al backend al finalizar la compra (crea Pedido + Detalles).
  static Future<void> createOrder(Order order) async {
    final profile = await ClientSession.get();
    if (profile == null || profile.idCliente.trim().isEmpty) {
      throw Exception('No hay cliente para asociar el pedido');
    }

    final detalles = order.items
        .map((item) => {
              'idProducto': item.id,
              'cantidad': item.quantity,
            })
        .toList();

    await _client.postJson(
      _createOrderPath,
      body: {
        'idCliente': profile.idCliente,
        'detalles': detalles,
      },
    );
  }

  /// Convierte la estructura compleja del backend a nuestro modelo [Order].
  static Order _orderFromApi(Map<String, dynamic> json) {
    final id = (json['idPedido'] ?? json['id'] ?? '').toString();
    final createdAt =
        (json['fecha_pedido'] ?? json['createdAt'] ?? '').toString();

    final detalles = json['detalles'] as List<dynamic>? ?? const [];
    final items = <CartItem>[];
    double total = 0;

    for (final raw in detalles) {
      if (raw is! Map<String, dynamic>) continue;
      final prod = raw['producto'] as Map<String, dynamic>?;
      if (prod == null) continue;
      final idProducto =
          (prod['idProducto'] ?? prod['id'] ?? '').toString();
      final nombre = (prod['nombre'] ?? '').toString();
      final imageUrl = prod['imageUrl'] as String?;
      final precioRaw = prod['precio'];
      double price;
      if (precioRaw is num) {
        price = precioRaw.toDouble();
      } else if (precioRaw is String) {
        price = double.tryParse(
                precioRaw.replaceAll('\$', '').replaceAll(',', '.').trim()) ??
            0;
      } else {
        price = 0;
      }
      final cantidad =
          (raw['cantidad'] is num) ? (raw['cantidad'] as num).toInt() : 1;

      final formattedPrice = '\$${price.toStringAsFixed(2)}';
      items.add(CartItem(
        id: idProducto,
        name: nombre,
        price: formattedPrice,
        quantity: cantidad,
        imageUrl: imageUrl,
      ));
      total += price * cantidad;
    }

    return Order(
      id: id,
      createdAt: createdAt,
      items: items,
      total: total,
      paymentLabel: null,
    );
  }

  /// Obtiene el detalle completo de un pedido del cliente autenticado.
  static Future<OrderDetailData> getOrderById(String idPedido) async {
    final profile = await ClientSession.get();
    if (profile == null || profile.idCliente.trim().isEmpty) {
      throw Exception('No hay cliente autenticado');
    }

    final response = await _client.getJsonMap(
      '$_myOrderDetailPath/$idPedido',
      headers: {'X-Client-ID': profile.idCliente},
    );

    if (response['success'] != true || response['data'] == null) {
      final message =
          response['message'] as String? ?? 'No se pudo obtener el pedido.';
      throw Exception(message);
    }

    final data = response['data'] as Map<String, dynamic>;
    return OrderDetailData.fromApi(data);
  }
}

/// Detalle enriquecido de un pedido: cliente, estado, pago, envío, productos.
class OrderDetailData {
  const OrderDetailData({
    required this.id,
    required this.createdAt,
    required this.estado,
    required this.clienteNombre,
    required this.clienteEmail,
    required this.items,
    required this.total,
    this.metodoPago,
    this.estadoEnvio,
  });

  final String id;
  final String createdAt;
  final String estado;
  final String clienteNombre;
  final String clienteEmail;
  final List<CartItem> items;
  final double total;
  final String? metodoPago;
  final String? estadoEnvio;

  int get itemCount => items.fold<int>(0, (sum, i) => sum + i.quantity);

  static OrderDetailData fromApi(Map<String, dynamic> json) {
    final id = (json['idPedido'] ?? json['id'] ?? '').toString();
    final createdAt =
        (json['fecha_pedido'] ?? json['createdAt'] ?? '').toString();
    final estado = (json['estado'] ?? '').toString();

    final cliente = json['cliente'] as Map<String, dynamic>?;
    final clienteNombre = (cliente?['nombre'] ?? '').toString();
    final clienteEmail = (cliente?['email'] ?? '').toString();

    String? metodoPago;
    String? estadoEnvio;
    final envio = json['envio'] as Map<String, dynamic>?;
    if (envio != null) {
      estadoEnvio = (envio['estado'] ?? '').toString();
      final mp = envio['metodoPago'] as Map<String, dynamic>?;
      if (mp != null) {
        metodoPago = (mp['tipo_pago'] ?? '').toString();
      }
    }

    final detalles = json['detalles'] as List<dynamic>? ?? const [];
    final items = <CartItem>[];
    double total = 0;

    for (final raw in detalles) {
      if (raw is! Map<String, dynamic>) continue;
      final prod = raw['producto'] as Map<String, dynamic>?;
      if (prod == null) continue;

      final idProducto =
          (prod['idProducto'] ?? prod['id'] ?? '').toString();
      final nombre = (prod['nombre'] ?? '').toString();
      final imageUrl = prod['imageUrl'] as String?;
      final precioRaw = prod['precio'];
      double price;
      if (precioRaw is num) {
        price = precioRaw.toDouble();
      } else if (precioRaw is String) {
        price = double.tryParse(
                precioRaw.replaceAll('\$', '').replaceAll(',', '.').trim()) ??
            0;
      } else {
        price = 0;
      }
      final cantidad =
          (raw['cantidad'] is num) ? (raw['cantidad'] as num).toInt() : 1;

      final formattedPrice = '\$${price.toStringAsFixed(2)}';
      items.add(CartItem(
        id: idProducto,
        name: nombre,
        price: formattedPrice,
        quantity: cantidad,
        imageUrl: imageUrl,
      ));
      total += price * cantidad;
    }

    return OrderDetailData(
      id: id,
      createdAt: createdAt,
      estado: estado,
      clienteNombre: clienteNombre,
      clienteEmail: clienteEmail,
      items: items,
      total: total,
      metodoPago: metodoPago,
      estadoEnvio: estadoEnvio,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sabor_sano/config/stripe_config.dart';
import 'package:sabor_sano/theme/app_theme.dart';
import 'package:sabor_sano/screens/home_screen.dart';
import 'package:sabor_sano/screens/category_screen.dart';
import 'package:sabor_sano/screens/info_web_screen.dart';
import 'package:sabor_sano/screens/cart_screen.dart';
import 'package:sabor_sano/screens/product_detail_screen.dart';
import 'package:sabor_sano/screens/register_client_screen.dart';
import 'package:sabor_sano/screens/login_screen.dart';
import 'package:sabor_sano/screens/my_orders_screen.dart';
import 'package:sabor_sano/screens/order_detail_screen.dart';
import 'package:sabor_sano/screens/splash_screen.dart';
import 'package:sabor_sano/screens/checkout_payment_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();
  runApp(const SaborSanoApp());
}

class SaborSanoApp extends StatelessWidget {
  const SaborSanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaborSano',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const HomeScreen(),
        '/category': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final id = args is String ? args : null;
          return CategoryScreen(categoryId: id);
        },
        '/info': (context) {
          final url = ModalRoute.of(context)?.settings.arguments as String?;
          return InfoWebScreen(url: url);
        },
        '/cart': (context) => const CartScreen(),
        '/product': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final map = args is Map ? Map<String, String>.from(args) : null;
          return ProductDetailScreen(
            productId: map?['id'],
            productName: map?['name'],
            productPrice: map?['price'],
            productImageUrl: map?['imageUrl'],
          );
        },
        '/login': (context) => const LoginScreen(),
        '/register': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final editMode = args is Map && args['edit'] == true;
          return RegisterClientScreen(editMode: editMode);
        },
        '/orders': (context) => const MyOrdersScreen(),
        '/order-detail': (context) {
          final id = ModalRoute.of(context)?.settings.arguments as String?;
          if (id == null || id.isEmpty) return const SizedBox.shrink();
          return OrderDetailScreen(orderId: id);
        },
        '/checkout-payment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is! Map) return const SizedBox.shrink();
          final orderId = args['orderId']?.toString() ?? '';
          final total = (args['total'] is num) ? (args['total'] as num).toDouble() : 0.0;
          if (orderId.isEmpty) return const SizedBox.shrink();
          return CheckoutPaymentScreen(orderId: orderId, total: total);
        },
      },
    );
  }
}

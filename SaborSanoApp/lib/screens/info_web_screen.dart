import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_theme.dart';

/// URL para la sección Información del menú. Cámbiala por tu enlace real.
const String kInfoUrl = 'https://pzapatav01.github.io/Solo_SaborSano_Web/informacion.html';

/// Pantalla que muestra una URL en WebView (para el ítem Información del menú).
class InfoWebScreen extends StatefulWidget {
  const InfoWebScreen({
    super.key,
    this.url,
    this.title = 'Información',
  });

  /// Si no se pasa, se usa [kInfoUrl] o el argumento de la ruta.
  final String? url;
  final String title;

  @override
  State<InfoWebScreen> createState() => _InfoWebScreenState();
}

class _InfoWebScreenState extends State<InfoWebScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final url = widget.url ?? kInfoUrl;
    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accentLime),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../theme/app_theme.dart';
import '../services/clients_repository.dart';
import 'info_web_screen.dart';

/// Pantalla de registro de cliente (nombre, dni, teléfono, email, dirección).
/// Se muestra al tocar Perfil en la navegación. Al completar el formulario redirige a Home.
class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _dni = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _direccion = TextEditingController();
  bool _isSubmitting = false;
  String? _apiError;

  @override
  void dispose() {
    _nombre.dispose();
    _dni.dispose();
    _telefono.dispose();
    _email.dispose();
    _direccion.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    setState(() => _apiError = null);
    try {
      await ClientsRepository.register(
        nombre: _nombre.text.trim(),
        dni: _dni.text.trim(),
        telefono: _telefono.text.trim(),
        email: _email.text.trim(),
        direccion: _direccion.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registro completado'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.accentLimeDark,
        ),
      );
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      // Si hay pantalla anterior (por ejemplo, Carrito), volvemos a ella.
      // Si no hay, volvemos al inicio.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      showBottomNav: true,
      showSearchBar: false,
      showFilterButton: false,
      currentNavIndex: 2,
      onNavTap: _onNavTap,
      onCartTap: () => Navigator.of(context).pushNamed('/cart'),
      onMenuCategoryTap: (id) => _onMenuCategoryTap(context, id),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
            child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Text(
                'Registro de cliente',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              if (_apiError != null) ...[
                Text(
                  _apiError!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Completa tus datos para continuar.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _nombre,
                label: 'Nombre',
                hint: 'Nombre completo',
                maxLength: 50,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _dni,
                label: 'DNI',
                hint: 'Número de identificación',
                maxLength: 50,
                keyboardType: TextInputType.text,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu DNI' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _telefono,
                label: 'Teléfono',
                hint: 'Ej: 999888777',
                maxLength: 15,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _email,
                label: 'Email',
                hint: 'correo@ejemplo.com',
                maxLength: 150,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'Email no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _direccion,
                label: 'Dirección',
                hint: 'Calle, número, ciudad',
                maxLength: 200,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu dirección' : null,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentLime,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isSubmitting ? 'Enviando...' : 'Registrarme'),
              ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLength,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../layouts/main_layout.dart';
import '../theme/app_theme.dart';
import '../services/clients_repository.dart';
import '../services/client_session.dart';
import '../utils/client_validators.dart';
import 'info_web_screen.dart';

/// Registro o edición de datos del cliente (nombre, DNI, teléfono, email, dirección).
class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key, this.editMode = false});

  /// Si true, siempre actualiza (PUT) en lugar de registrar (POST).
  final bool editMode;

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
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loadingProfile = false;
  bool _isEditing = false;
  String? _apiError;
  String? _avatarLocalPath;
  final ImagePicker _imagePicker = ImagePicker();

  void _fillFieldsFromProfile(ClientProfile profile) {
    _nombre.text = profile.nombre;
    _dni.text = profile.dni;
    _telefono.text = profile.telefono;
    _email.text = profile.email;
    _direccion.text = profile.direccion;
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editMode;
    _bootstrapProfile();
  }

  Future<void> _bootstrapProfile() async {
    final local = await ClientSession.get();
    if (local != null && local.idCliente.trim().isNotEmpty) {
      _isEditing = true;
      _fillFieldsFromProfile(local);
    }
    await _loadExistingProfile();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _dni.dispose();
    _telefono.dispose();
    _email.dispose();
    _direccion.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _loadExistingProfile() async {
    setState(() => _loadingProfile = true);
    try {
      final profile = await ClientsRepository.fetchMyProfile();
      if (!mounted) return;
      if (profile != null) {
        _isEditing = true;
        _fillFieldsFromProfile(profile);
      }
    } catch (_) {
      // Sin perfil: modo registro.
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  List<String> _collectValidationErrors() {
    final errors = <String>[];

    if (_nombre.text.trim().isEmpty) {
      errors.add('Ingresa tu nombre');
    }
    final dniErr = ClientValidators.dniError(_dni.text);
    if (dniErr != null) errors.add(dniErr);
    if (_telefono.text.trim().isEmpty) {
      errors.add('Ingresa tu teléfono');
    }
    final emailErr = ClientValidators.emailError(_email.text);
    if (emailErr != null) errors.add(emailErr);
    if (_direccion.text.trim().isEmpty) {
      errors.add('Ingresa tu dirección');
    }
    if (!_isEditing) {
      final passwordErr = ClientValidators.passwordError(_password.text);
      if (passwordErr != null) errors.add(passwordErr);
      final confirmErr = ClientValidators.confirmPasswordError(
        _confirmPassword.text,
        _password.text,
      );
      if (confirmErr != null) errors.add(confirmErr);
    }

    return errors;
  }

  Future<void> _showValidationAlert(List<String> errors) async {
    if (!mounted || errors.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Revisa tus datos'),
        content: Text(
          errors.map((e) => '• $e').join('\n'),
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
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

  Future<void> _pickAvatar() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _avatarLocalPath = file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo seleccionar la imagen'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _apiError = null);

    final errors = _collectValidationErrors();
    if (errors.isNotEmpty) {
      await _showValidationAlert(errors);
      _formKey.currentState?.validate();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final nombre = _nombre.text.trim();
    final dni = ClientValidators.normalizeDni(_dni.text);
    final telefono = _telefono.text.trim();
    final email = _email.text.trim();
    final direccion = _direccion.text.trim();

    try {
      final session = await ClientSession.get();
      final shouldUpdate = _isEditing ||
          widget.editMode ||
          (session != null && session.idCliente.trim().isNotEmpty);

      if (shouldUpdate) {
        await ClientsRepository.updateProfile(
          nombre: nombre,
          dni: dni,
          telefono: telefono,
          email: email,
          direccion: direccion,
        );
      } else {
        await ClientsRepository.register(
          nombre: nombre,
          dni: dni,
          telefono: telefono,
          email: email,
          direccion: direccion,
          password: _password.text,
          avatarPath: _avatarLocalPath,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Datos actualizados' : 'Registro completado',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.accentLimeDark,
        ),
      );
      setState(() => _isSubmitting = false);
      if (!mounted) return;
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
    final title = _isEditing ? 'Editar mis datos' : 'Registro de cliente';
    final subtitle = _isEditing
        ? 'Actualiza tu información personal.'
        : 'Completa tus datos para continuar.';
    final buttonLabel =
        _isEditing ? 'Guardar cambios' : 'Registrarme';

    return MainLayout(
      showBottomNav: true,
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
            child: _loadingProfile
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentLime,
                      ),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor:
                                      AppTheme.accentLime.withOpacity(0.15),
                                  backgroundImage: _avatarLocalPath != null
                                      ? FileImage(File(_avatarLocalPath!))
                                      : null,
                                  child: _avatarLocalPath == null
                                      ? Icon(
                                          Icons.person_outline,
                                          size: 48,
                                          color: AppTheme.accentLimeDark,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed:
                                      _isSubmitting ? null : _pickAvatar,
                                  icon: const Icon(Icons.photo_library_outlined),
                                  label: Text(
                                    _avatarLocalPath == null
                                        ? 'Elegir foto de perfil (opcional)'
                                        : 'Cambiar foto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildField(
                          controller: _nombre,
                          label: 'Nombre',
                          hint: 'Nombre completo',
                          maxLength: 50,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingresa tu nombre'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _dni,
                          label: 'DNI',
                          hint: '12345678Z',
                          maxLength: 9,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9A-Za-z]'),
                            ),
                            LengthLimitingTextInputFormatter(9),
                          ],
                          validator: ClientValidators.dniError,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _telefono,
                          label: 'Teléfono',
                          hint: 'Ej: 612345678',
                          maxLength: 15,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingresa tu teléfono'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _email,
                          label: 'Email',
                          hint: 'correo@ejemplo.com',
                          maxLength: 150,
                          keyboardType: TextInputType.emailAddress,
                          validator: ClientValidators.emailError,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _direccion,
                          label: 'Dirección',
                          hint: 'Calle, número, ciudad',
                          maxLength: 200,
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingresa tu dirección'
                              : null,
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _password,
                            label: 'Contraseña',
                            hint: 'Mínimo 8 caracteres',
                            maxLength: 128,
                            obscureText: _obscurePassword,
                            validator: ClientValidators.passwordError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _confirmPassword,
                            label: 'Confirmar contraseña',
                            hint: 'Repite tu contraseña',
                            maxLength: 128,
                            obscureText: _obscureConfirmPassword,
                            validator: (v) =>
                                ClientValidators.confirmPasswordError(
                              v,
                              _password.text,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                          ),
                        ],
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
                          child: Text(
                            _isSubmitting ? 'Enviando...' : buttonLabel,
                          ),
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () =>
                                    Navigator.of(context).pushNamed('/login'),
                            child: const Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                            ),
                          ),
                        ],
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
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
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
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: '',
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Validaciones de cliente (formato España).
class ClientValidators {
  ClientValidators._();

  static const _dniControlLetters = 'TRWAGMYFPDXBNJZSQVHLCKE';

  /// Email con formato válido (no texto libre).
  static bool isValidEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  static String? emailError(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu email';
    }
    if (!isValidEmail(value)) {
      return 'Ingresa un correo válido (ej: nombre@ejemplo.com)';
    }
    return null;
  }

  /// DNI español: 8 dígitos + 1 letra de control al final.
  static String normalizeDni(String value) {
    return value.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  }

  static bool isValidSpanishDni(String? value) {
    final dni = normalizeDni(value ?? '');
    if (!RegExp(r'^\d{8}[A-Z]$').hasMatch(dni)) return false;
    final number = int.tryParse(dni.substring(0, 8));
    if (number == null) return false;
    return _dniControlLetters[number % 23] == dni[8];
  }

  static const int minPasswordLength = 8;

  static String? passwordError(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < minPasswordLength) {
      return 'La contraseña debe tener al menos $minPasswordLength caracteres';
    }
    return null;
  }

  static String? confirmPasswordError(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? dniError(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu DNI';
    }
    final dni = normalizeDni(value);
    if (!RegExp(r'^\d{8}[A-Z]$').hasMatch(dni)) {
      return 'El DNI debe tener 8 números y 1 letra al final (ej: 12345678Z)';
    }
    if (!isValidSpanishDni(value)) {
      return 'La letra del DNI no es válida';
    }
    return null;
  }
}

/// Validações reutilizáveis dos formulários (testadas em test/validators_test.dart).
class Validators {
  static final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  static final _cpf = RegExp(r'\d{3}\.?\d{3}\.?\d{3}-?\d{2}');
  static final _phone = RegExp(r'\(?\d{2}\)?\s?9?\d{4}[-\s]?\d{4}');

  /// Detecta e-mail, CPF ou telefone digitados em texto livre (privacidade).
  static bool hasPersonalData(String text) =>
      _email.hasMatch(text) || _cpf.hasMatch(text) || _phone.hasMatch(text);

  static String? description(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Descreva o que está acontecendo.';
    if (t.length < 10) return 'Use ao menos 10 caracteres.';
    if (t.length > 280) return 'Máximo de 280 caracteres.';
    if (hasPersonalData(t)) {
      return 'Não inclua e-mail, telefone ou CPF: o registro é anônimo.';
    }
    return null;
  }

  static String? location(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe um ponto de referência.';
    if (t.length < 3) return 'Use ao menos 3 caracteres.';
    if (t.length > 80) return 'Máximo de 80 caracteres.';
    if (hasPersonalData(t)) return 'Não inclua dados pessoais no local.';
    return null;
  }

  static double? parseNumber(String v) =>
      double.tryParse(v.trim().replaceAll(',', '.'));

  static String? numberInRange(
    String? v, {
    required double min,
    required double max,
    required String label,
  }) {
    if (v == null || v.trim().isEmpty) return 'Informe $label.';
    final n = parseNumber(v);
    if (n == null) return 'Digite um número válido.';
    if (n < min || n > max) {
      return '$label deve estar entre ${min.toStringAsFixed(0)} e ${max.toStringAsFixed(0)}.';
    }
    return null;
  }
}

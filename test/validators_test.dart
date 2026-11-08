import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/core/validators.dart';

void main() {
  group('description', () {
    test('rejeita vazio e texto curto', () {
      expect(Validators.description(''), isNotNull);
      expect(Validators.description('curto'), isNotNull);
    });
    test('aceita texto válido', () {
      expect(Validators.description('Vazamento grande na calçada da praça'), isNull);
    });
    test('bloqueia e-mail, telefone e CPF', () {
      expect(Validators.description('Falar com joao@email.com sobre o vazamento'), isNotNull);
      expect(Validators.description('Ligar para (11) 91234-5678 sobre o lixo'), isNotNull);
      expect(Validators.description('Morador CPF 123.456.789-09 reclamou'), isNotNull);
    });
  });

  group('location', () {
    test('valida tamanho mínimo', () {
      expect(Validators.location(''), isNotNull);
      expect(Validators.location('ab'), isNotNull);
      expect(Validators.location('Praça da Sé'), isNull);
    });
  });

  group('numberInRange', () {
    String? v(String? s) => Validators.numberInRange(s, min: 5, max: 100, label: 'O valor');
    test('rejeita vazio, texto e fora da faixa', () {
      expect(v(''), isNotNull);
      expect(v('abc'), isNotNull);
      expect(v('3'), isNotNull);
      expect(v('150'), isNotNull);
    });
    test('aceita valores válidos, inclusive com vírgula', () {
      expect(v('20'), isNull);
      expect(v('12,5'), isNull);
    });
  });
}

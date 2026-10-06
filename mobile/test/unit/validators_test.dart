import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/core/utils/validators.dart';

void main() {
  group('VehicaValidators Unit Tests', () {
    test('TC-01: Email validation accepts valid email', () {
      expect(VehicaValidators.validateEmail('user@vehica.com'), isNull);
      expect(VehicaValidators.validateEmail('admin@vehica.com'), isNull);
    });

    test('TC-01: Email validation rejects invalid email', () {
      expect(VehicaValidators.validateEmail(''), isNotNull);
      expect(VehicaValidators.validateEmail('invalid-email'), isNotNull);
      expect(VehicaValidators.validateEmail('user@'), isNotNull);
    });

    test('TC-02: Password validation requires at least 8 characters (BR-02)', () {
      expect(VehicaValidators.validatePassword('1234567'), isNotNull);
      expect(VehicaValidators.validatePassword('12345678'), isNull);
      expect(VehicaValidators.validatePassword('password123'), isNull);
    });

    test('TC-05: Date range validation requires startDate < endDate (BR-08)', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final yesterday = now.subtract(const Duration(days: 1));

      expect(VehicaValidators.validateDateRange(now, tomorrow), isNull);
      expect(VehicaValidators.validateDateRange(now, now), isNotNull); // Equal dates rejected
      expect(VehicaValidators.validateDateRange(tomorrow, now), isNotNull); // Reversed rejected
      expect(VehicaValidators.validateDateRange(now, yesterday), isNotNull); // Past end date rejected
    });
  });
}

import 'package:intl/intl.dart';

class VehicaFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  static String formatCurrency(dynamic amount) {
    if (amount == null) return '0 ₫';
    if (amount is num) {
      return _currencyFormat.format(amount);
    }
    final parsed = double.tryParse(amount.toString());
    return parsed != null ? _currencyFormat.format(parsed) : '$amount ₫';
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime);
  }

  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }
}

class Formatters {
  static String currency(dynamic amount) => VehicaFormatters.formatCurrency(amount);
  static String date(DateTime? date) => VehicaFormatters.formatDate(date);
  static String dateTime(DateTime? dateTime) => VehicaFormatters.formatDateTime(dateTime);
}

class VehicaValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length > 120) {
      return 'Họ tên không được vượt quá 120 ký tự';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    final phoneRegex = RegExp(r'^(?:0|\+84)(?:3|5|7|8|9)\d{8}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Số điện thoại không hợp lệ (10 chữ số, đầu 03, 05, 07, 08, 09)';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  static String? validateLicensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập biển số xe';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập giá thuê';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Giá thuê phải lớn hơn 0';
    }
    return null;
  }

  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Vui lòng chọn ngày nhận và ngày trả xe';
    }
    if (!startDate.isBefore(endDate)) {
      return 'Ngày trả xe phải sau ngày nhận xe';
    }
    return null;
  }
}

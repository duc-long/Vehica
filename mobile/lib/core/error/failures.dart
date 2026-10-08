abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại đường truyền.'});
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({required super.message, this.fieldErrors, super.statusCode = 400});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.', super.statusCode = 401});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Bạn không có quyền thực hiện thao tác này.', super.statusCode = 403});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.statusCode = 404});
}

class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, super.statusCode = 409});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Lỗi truy xuất bộ nhớ tạm.'});
}

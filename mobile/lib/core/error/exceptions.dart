class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Lỗi lưu trữ dữ liệu cục bộ.'});

  @override
  String toString() => 'CacheException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({this.message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'});

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? detail;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.detail,
  });

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({
    this.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
  });
  @override
  String toString() => message;
}

class TimeoutApiException implements Exception {
  final String message;
  const TimeoutApiException({
    this.message = 'Yêu cầu đã hết thời gian. Vui lòng thử lại.',
  });
  @override
  String toString() => message;
}

class AuthException extends ApiException {
  const AuthException({
    super.message = 'Phiên đã hết hạn. Vui lòng đăng nhập lại.',
  }) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({super.message = 'Bạn không có quyền truy cập.'})
    : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Không tìm thấy dữ liệu.'})
    : super(statusCode: 404);
}

class ValidationException extends ApiException {
  final Map<String, String>? errors;
  const ValidationException({
    super.message = 'Dữ liệu không hợp lệ.',
    this.errors,
  }) : super(statusCode: 400);
}

class ServerException extends ApiException {
  const ServerException({super.message = 'Lỗi hệ thống. Vui lòng thử lại sau.'})
    : super(statusCode: 500);
}

class ParseException implements Exception {
  final String message;
  const ParseException({this.message = 'Dữ liệu phản hồi không hợp lệ.'});
  @override
  String toString() => message;
}

String getErrorMessage(dynamic error) {
  if (error is ApiException) return error.message;
  return error.toString().replaceFirst('Exception: ', '');
}

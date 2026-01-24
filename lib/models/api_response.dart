class ApiResponse {
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;
  final int? statusCode;
}

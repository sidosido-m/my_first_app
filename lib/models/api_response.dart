class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});
}
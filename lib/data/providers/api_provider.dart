import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/constants/app_constants.dart';
import '../../shared/services/secure_storage_service.dart';

/// Base API provider with authentication handling
class ApiProvider {
  static final _ss = SecureStorageService.instance;

  /// Convert raw network exceptions into clean, translatable messages.
  static String _friendlyError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('failed host lookup') ||
        msg.contains('no address associated') ||
        msg.contains('socketexception') ||
        msg.contains('connection refused') ||
        msg.contains('network is unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (msg.contains('timed out') || msg.contains('timeout')) {
      return 'Connection timed out. Please try again later.';
    }
    if (msg.contains('handshake') || msg.contains('certificate')) {
      return 'Secure connection failed. Please try again later.';
    }
    return 'Connection error. Please try again.';
  }

  /// Get saved auth token
  static String? get token => _ss.read(AppConstants.storageToken);

  /// Check if user is logged in
  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  /// Standard headers with auth token
  static Map<String, String> get _headers => {
        'Content-Type': 'application/x-www-form-urlencoded',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// POST request
  static Future<ApiResponse> post(String url,
      {Map<String, String>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: body,
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: _friendlyError(e),
      );
    }
  }

  /// GET request
  static Future<ApiResponse> get(String url,
      {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http.get(uri, headers: _headers);
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: _friendlyError(e),
      );
    }
  }

  /// Multipart POST request (for file uploads)
  static Future<ApiResponse> uploadMultipart(
    String url, {
    Map<String, String>? fields,
    required String fileField,
    required String filePath,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (fields != null) request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: _friendlyError(e),
      );
    }
  }

  /// Parse the standard JSON response from our PHP backend
  static ApiResponse _parseResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final status = body['status'] as String?;
        return ApiResponse(
          success: status == 'success',
          message: body['message'] as String?,
          data: body['data'],
          rawBody: body,
        );
      }
      return ApiResponse(
        success: false,
        message: 'Invalid response format',
      );
    } catch (e) {
      // Non-JSON response (PHP error page)
      return ApiResponse(
        success: false,
        message: 'Server error: Invalid JSON response',
        rawBody: {'raw': response.body},
      );
    }
  }

  /// Save auth data after login.
  /// Cache is updated synchronously; encrypted persist is fire-and-forget.
  static void saveAuth({
    required String token,
    required String role,
    required String userId,
    required String userName,
    required String userEmail,
    String? vendorId,
    String? vendorName,
  }) {
    _ss.write(AppConstants.storageToken, token);
    _ss.write(AppConstants.storageRole, role);
    _ss.write(AppConstants.storageUserId, userId);
    _ss.write(AppConstants.storageUserName, userName);
    _ss.write(AppConstants.storageUserEmail, userEmail);
    if (vendorId != null) {
      _ss.write(AppConstants.storageVendorId, vendorId);
    }
    if (vendorName != null) {
      _ss.write(AppConstants.storageVendorName, vendorName);
    }
  }

  /// Clear all stored auth data
  static void clearAuth() {
    _ss.remove(AppConstants.storageToken);
    _ss.remove(AppConstants.storageRole);
    _ss.remove(AppConstants.storageUserId);
    _ss.remove(AppConstants.storageUserName);
    _ss.remove(AppConstants.storageUserEmail);
    _ss.remove(AppConstants.storageVendorId);
    _ss.remove(AppConstants.storageVendorName);
  }

  /// Get stored user role
  static String? get storedRole =>
      _ss.read(AppConstants.storageRole);
  static String? get storedUserId =>
      _ss.read(AppConstants.storageUserId);
  static String? get storedUserName =>
      _ss.read(AppConstants.storageUserName);
  static String? get storedUserEmail =>
      _ss.read(AppConstants.storageUserEmail);
}

/// Standard API response wrapper
class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final Map<String, dynamic>? rawBody;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.rawBody,
  });
}

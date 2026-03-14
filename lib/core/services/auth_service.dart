import 'package:dio/dio.dart';
import 'package:helpi_student/core/l10n/app_strings.dart';
import 'package:helpi_student/core/network/api_client.dart';
import 'package:helpi_student/core/network/api_endpoints.dart';
import 'package:helpi_student/core/network/token_storage.dart';

/// Rezultat auth operacije.
class AuthResult {
  final bool success;
  final String? message;
  final int? userId;
  final String? userType;

  const AuthResult({
    required this.success,
    this.message,
    this.userId,
    this.userType,
  });
}

/// Servis za autentikaciju — login, logout, forgot/reset password.
class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  /// Mapira backend int enum (0=Admin, 1=Student, 2=Customer) u string.
  static String _userTypeFromInt(dynamic value) {
    if (value is String) return value;
    switch (value as int) {
      case 0:
        return 'Admin';
      case 1:
        return 'Student';
      case 2:
        return 'Customer';
      default:
        return 'Unknown';
    }
  }

  /// Prijava korisnika.
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final body = response.data as Map<String, dynamic>;
      final token = body['token'] as String?;
      final userId = body['userId'];
      final userType = _userTypeFromInt(body['userType']);

      if (token != null) {
        await TokenStorage.saveAccessToken(token);
        await TokenStorage.saveUserId(userId.toString());
        await TokenStorage.saveUserType(userType);
      }

      return AuthResult(
        success: true,
        userId: userId is int ? userId : int.tryParse(userId.toString()),
        userType: userType,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        return AuthResult(
          success: false,
          message: AppStrings.invalidCredentials,
        );
      }
      return AuthResult(success: false, message: AppStrings.loginError);
    } catch (_) {
      return AuthResult(success: false, message: AppStrings.loginError);
    }
  }

  /// Odjava — briše tokene.
  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  /// Provjera postoji li spremljen token.
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Zahtjev za reset kod na email.
  Future<AuthResult> forgotPassword(String email) async {
    try {
      await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
      return const AuthResult(success: true);
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map<String, dynamic>?)?['message'] as String?;
      return AuthResult(success: false, message: msg ?? AppStrings.loginError);
    } catch (_) {
      return AuthResult(success: false, message: AppStrings.loginError);
    }
  }

  /// Reset lozinke s kodom.
  Future<AuthResult> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'resetCode': code, 'newPassword': newPassword},
      );
      return const AuthResult(success: true);
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map<String, dynamic>?)?['message'] as String?;
      return AuthResult(success: false, message: msg ?? AppStrings.loginError);
    } catch (_) {
      return AuthResult(success: false, message: AppStrings.loginError);
    }
  }
}

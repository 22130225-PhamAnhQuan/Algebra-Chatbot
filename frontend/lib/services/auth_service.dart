// lib/services/auth_service.dart
//
// Map tới app/routers/auth_router.py:
//   POST /auth/register
//   POST /auth/login
//   POST /auth/forgot-password
//   POST /auth/verify-otp
//   POST /auth/reset-password
//
import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final _api = ApiClient();

  // ── POST /auth/register ────────────────────────────────────────
  // Body: {email, name, password}
  // Returns: {message, user_id}

  Future<int> register({
    required String email,
    required String name,
    required String password,
  }) async {
    final res = await _api.post(
      '/auth/register',
      {'email': email, 'name': name, 'password': password},
    );
    return res['user_id'] as int;
  }

  // ── POST /auth/login ───────────────────────────────────────────
  // Body: {email, password}
  // Returns: {access_token, token_type}

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      '/auth/login',
      {'email': email, 'password': password},
    );
    final token = res['access_token'] as String;
    await _api.saveToken(token);
    return token;
  }

  // ── POST /auth/forgot-password ─────────────────────────────────
  // Body: {email}
  // Returns: {message}

  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', {'email': email});
  }

  // ── POST /auth/verify-otp ──────────────────────────────────────
  // Body: {email, otp}
  // Returns: {message}

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await _api.post('/auth/verify-otp', {'email': email, 'otp': otp});
  }

  // ── POST /auth/reset-password ──────────────────────────────────
  // Body: {email, new_password}
  // Returns: {message}

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _api.post(
      '/auth/reset-password',
      {'email': email, 'new_password': newPassword},
    );
  }

  // ── Logout (xoá token local) ───────────────────────────────────

  Future<void> logout() async {
    await _api.deleteToken();
  }

  Future<bool> get isLoggedIn => _api.hasToken;
}

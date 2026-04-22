// // lib/services/user_service.dart
// //
// // Map tới app/routers/user_router.py:
// //   GET  /users/profile
// //   PUT  /users/update
// //   PUT  /users/change-password
// //
// import '../core/api_client.dart';
// import '../models/user_model.dart';
//
// class UserService {
//   final _api = ApiClient();
//
//   // ── GET /users/profile ─────────────────────────────────────────
//   // Header: Authorization: Bearer <token>
//   // Returns: {id, email, name}
//
//   Future<UserModel> getProfile() async {
//     final res = await _api.get('/users/profile');
//     return UserModel.fromJson(res as Map<String, dynamic>);
//   }
//
//   // ── PUT /users/update ──────────────────────────────────────────
//   // Body: {name, email}
//   // Returns: {message, user: {id, email, name}}
//
//   Future<UserModel> updateProfile({
//     required String name,
//     required String email,
//   }) async {
//     final res = await _api.put('/users/update', {'name': name, 'email': email});
//     return UserModel.fromJson(res['user'] as Map<String, dynamic>);
//   }
//
//   // ── PUT /users/change-password ─────────────────────────────────
//   // Body: {old_password, new_password}
//   // Returns: {message}
//
//   Future<void> changePassword({
//     required String oldPassword,
//     required String newPassword,
//   }) async {
//     await _api.put('/users/change-password', {
//       'old_password': oldPassword,
//       'new_password': newPassword,
//     });
//   }
// }

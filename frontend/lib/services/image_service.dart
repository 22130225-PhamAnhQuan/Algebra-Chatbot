// // lib/services/image_service.dart
// //
// // Xử lý pick ảnh từ camera/gallery và convert sang base64 để gửi lên AI
// //
// import 'dart:convert';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
//
// class ImageService {
//   final ImagePicker _picker = ImagePicker();
//
//   /// Mở camera để chụp ảnh
//   Future<String?> pickFromCamera() async {
//     final image = await _picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 85,
//       maxWidth: 1920,
//       maxHeight: 1080,
//     );
//     return _toBase64(image);
//   }
//
//   /// Mở thư viện để chọn ảnh
//   Future<String?> pickFromGallery() async {
//     final image = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//       maxWidth: 1920,
//       maxHeight: 1080,
//     );
//     return _toBase64(image);
//   }
//
//   Future<String?> _toBase64(XFile? image) async {
//     if (image == null) return null;
//     final bytes = await File(image.path).readAsBytes();
//     return base64Encode(bytes);
//   }
// }

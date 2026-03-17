// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
// import 'home_screen.dart'; // Màn hình chính sau này của bạn

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // Chờ 3 giây để tạo hiệu ứng thương hiệu
    await Future.delayed(Duration(seconds: 3));

    // Kiểm tra xem đã có Token lưu trong máy chưa
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      // Nếu có Token, vào thẳng trang chính (đã đăng nhập)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      // Nếu chưa có, chuyển đến trang Đăng nhập
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Màu chủ đạo của app
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bạn có thể thay Icon bằng Logo đồ án của mình
            Icon(Icons.auto_stories, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "TOÁN HỌC AI",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Hỗ trợ giải toán Đại số THCS",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(color: Colors.white), // Vòng xoay chờ
          ],
        ),
      ),
    );
  }
}
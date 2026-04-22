import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  void register() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    bool success = await ApiService.register(
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo tài khoản thành công")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tại khoản đã tồn tại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 12),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Icon(Icons.person_add_alt_1,
                        size: 70,
                        color: Colors.deepPurple),

                    const SizedBox(height: 15),

                    Text(
                      "Create Account",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextFormField(
                      controller: usernameController,
                      validator: (value) =>
                      value!.isEmpty ? "Nhập username" : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: emailController,
                      validator: (value) =>
                      value!.contains("@") ? null : "Email không hợp lệ",
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      validator: (value) =>
                      value!.length < 6 ? "Mật khẩu >= 6 ký tự" : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                        ),
                        onPressed: isLoading ? null : register,
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Đã có tài khoản? Đăng nhập"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:demo_topic10/Screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  // SnackBar
  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess
            ? Colors.green.shade600
            : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Đăng ký Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );

      final user = userCredential.user;

      // Lưu Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'email': user.email,
        'lastLogin': Timestamp.now(),
      }, SetOptions(merge: true));
      _showSnackBar("Đăng ký thành công!", true);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Đăng ký thất bại";

      if (e.code == 'email-already-in-use') {
        message = "Email đã được sử dụng";
      } else if (e.code == 'weak-password') {
        message = "Mật khẩu quá yếu";
      } else if (e.code == 'invalid-email') {
        message = "Email không hợp lệ";
      }

      _showSnackBar(message, false);
      debugPrint("FirebaseAuth Error: ${e.message}");
    } catch (e) {
      _showSnackBar("Có lỗi xảy ra!", false);
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade800, Colors.orange.shade400],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud, size: 70, color: Colors.orange),

                      const SizedBox(height: 12),

                      const Text(
                        "Dăng ký tài khoản",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // EMAIL
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập Email';
                          }

                          final emailRegex = RegExp(
                            r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                          );

                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Email không hợp lệ';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD
                      TextFormField(
                        controller: passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }

                          if (value.length < 6) {
                            return 'Mật khẩu tối thiểu 6 ký tự';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // BUTTON REGISTER
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "ĐĂNG KÝ TÀI KHOẢN",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // BUTTON BACK
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.home_outlined),
                          label: const Text("QUAY VỀ TRANG CHỦ"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade800,
                            side: BorderSide(color: Colors.orange.shade800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

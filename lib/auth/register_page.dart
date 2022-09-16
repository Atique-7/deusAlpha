import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  /// text controllers ///
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.all_inclusive_rounded,
                    size: 100,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 25),
                  Text("Hello Stranger!",
                      style: GoogleFonts.bebasNeue(
                          fontSize: 52, color: Colors.black)),
                  const SizedBox(height: 15),
                  const Text(
                    "Register below with your details!",
                    style: TextStyle(fontSize: 17, color: Colors.black),
                  ),
                  const SizedBox(height: 50),

                  /// Email Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7.0),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: false,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(top: 14),
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: Colors.black),
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// Password Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7.0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          enableSuggestions: false,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(top: 14),
                              prefixIcon: Icon(
                                Icons.password_outlined,
                                color: Colors.black,
                              ),
                              border: InputBorder.none,
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// Confirm Password Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7.0),
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          enableSuggestions: false,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(top: 14),
                              prefixIcon: Icon(
                                Icons.password_sharp,
                                color: Colors.black,
                              ),
                              border: InputBorder.none,
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// Sign-up button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () => signUp(),
                      child: Container(
                        padding: const EdgeInsets.all(23),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// Register button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already a member?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(width: 3),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: const Text(
                          "Login now",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "All fields are required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
    } else if (!EmailValidator.validate(_emailController.text.trim())) {
      Get.snackbar(
        "Error",
        "Enter a valid Email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
    } else if (_passwordController.text.trim().isAlphabetOnly ||
        _passwordController.text.trim().length < 6) {
      Get.snackbar(
        "Error",
        "Make sure the Password uses numbers and is minimum of 6 characters",
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
    } else if (checkPassword()) {
      EasyLoading.instance
        ..indicatorType = EasyLoadingIndicatorType.dualRing
        ..indicatorSize = 45.0
        ..radius = 10.0
        ..userInteractions = false
        ..dismissOnTap = false;
      EasyLoading.show(
        status: "Loading...",
      );

      try {
        dynamic auth = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim());

        if (auth != null) {
          EasyLoading.dismiss();
          EasyLoading.showToast("We are delighted to have you onboard!",
              duration: const Duration(milliseconds: 800), dismissOnTap: false);
        }
      } catch (e) {
        EasyLoading.dismiss();
        Get.snackbar(
          "Error",
          "Wrong Credentials",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
          colorText: Colors.pink,
          icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
          ),
        );
      }
    }
  }

  bool checkPassword() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      Get.snackbar(
        "Error",
        "Passwords do not match!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
      return false;
    }
  }
}

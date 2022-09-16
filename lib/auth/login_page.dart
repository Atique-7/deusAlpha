import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:productivity_monster/provider/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../allConstants/firestore_constants.dart';
import 'forgotPasswordPage.dart';


class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInProvider googleSignInProvider = Provider.of<GoogleSignInProvider>(context);

    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.all_inclusive_rounded,
                  size: 100,
                  color: Colors.black,),
                  const SizedBox(height: 25),
                  Text(
                    "Hello There!",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 52,
                      color: Colors.black
                    )
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Lets Get You In!",
                    style: TextStyle(fontSize: 18, color: Colors.black),
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
                            contentPadding: EdgeInsets.only(top:14),
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
                              border: InputBorder.none, hintText: "Email", hintStyle: TextStyle(color: Colors.black)),
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
                            contentPadding: EdgeInsets.only(top:14),
                            prefixIcon: Icon(Icons.password_outlined, color: Colors.black,),
                              border: InputBorder.none, hintText: 'Password', hintStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => forgotPassword(),
                          child: Text("Forgot Password?", style: GoogleFonts.aBeeZee(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  /// Sign-in button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () => signIn(),
                      child: Container(
                        padding: const EdgeInsets.all(23),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text(
                            "Sign In",
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
                      const Text("Not a member?",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(width: 3),
                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: const Text(
                          "Register Now",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                 const SizedBox(height: 30),
                 Container(
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(30),
                     color: Colors.black
                   ),
                   child: IconButton(onPressed: () async{
                     await googleSignInProvider.signInHandler();
                   }, icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red)),
                 )

                ],
              ),
            ),
          ),
        ));
  }

  Future signIn() async{
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
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
    }

    else if(!EmailValidator.validate(_emailController.text.trim())) {
      Get.snackbar(
        "Error",
        "Enter valid email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
    }

    else if(_passwordController.text.trim().isAlphabetOnly || _passwordController.text.trim().length < 6) {
      Get.snackbar(
        "Error",
        "Make sure the Password uses numbers and is minimum of 6 characters",
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
    }

    else {

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
        dynamic auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim()
        );

        if(auth != null){
          EasyLoading.dismiss();
          EasyLoading.showToast("Welcome Back",
              duration: const Duration(milliseconds: 800),
              dismissOnTap: false
          );
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

  void forgotPassword() {
    EasyLoading.showToast("Good Luck!",
    duration: const Duration(milliseconds: 500),
    dismissOnTap: true);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const ForgotPasswordPage();
    }));
  }


}

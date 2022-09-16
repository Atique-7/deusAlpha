import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future passwordReset() async {

    if (_emailController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "Email is required.",
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
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
        EasyLoading.dismiss();
        EasyLoading.showSuccess(
            "Reset Email Sent. Check your Mail.",
            duration: const Duration(milliseconds: 2000),
            dismissOnTap: true);
        Get.back();
      } on FirebaseAuthException catch (e) {
        EasyLoading.dismiss();
        Get.snackbar(
          "Something went wrong.",
          "Email is invalid or User has been deleted.",
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

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: _appbar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const SizedBox(height: 100),
            const Icon(Icons.all_inclusive_rounded,
              size: 150,
              color: Colors.black,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text("Rest easy, we've got your back.", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height:90),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text("Enter your email to reset the password.", style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 25),
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
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: GestureDetector(
                onTap: () => passwordReset(),
                child: Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text(
                      "Send Reset Email",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  _appbar() {
    return AppBar(
      elevation: 0,
    );
  }


}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

const Color darkGreyColor = Color(0xFF121212);
const Color bluishColor = Color(0xFF4e5ae8);
const Color primaryColor = bluishColor;

class Themes {
  static final light = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Color(0xFF2196F3),
      ),
      backgroundColor: Colors.white,
      brightness: Brightness.light);

  static final dark = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Color(0xFF151026),
      ),
      backgroundColor: darkGreyColor,
      brightness: Brightness.dark);
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato (
    textStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Get.isDarkMode ? Colors.grey[400] : Colors.grey
    )
  );
}

TextStyle get headingStyle {
  return GoogleFonts.lato (
      textStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Get.isDarkMode ? Colors.white : Colors.black
      )
  );
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Get.isDarkMode ? Colors.white : Colors.black
      )
  );
}

TextStyle get subTitleStyle {
  return GoogleFonts.lato (
      textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Get.isDarkMode ? Colors.grey[100] : Colors.grey[700]
      )
  );
}

TextStyle get phoneTitleStyle {
  return GoogleFonts.lato (
      textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Get.isDarkMode ? Colors.grey[300] : Colors.grey[500]
      )
  );
}


TextStyle get lastSeenTitleStyle {
  return GoogleFonts.lato (
      textStyle: TextStyle(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          color: Get.isDarkMode ? Colors.grey[100] : Colors.grey[700]
      )
  );
}



TextStyle get colorTitleStyle {
  return GoogleFonts.lato (
      textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Get.isDarkMode ? Colors.white : Colors.black
      )
  );
}
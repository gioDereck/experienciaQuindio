import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomColors {
  static Color getBodyColor() {
    return Get.isDarkMode ? bodyColorDark : bodyColor;
  }

  static Color getContainerColor() {
    return Get.isDarkMode ? containerColorDark : whiteColor;
  }

  static Color getShadowColor() {
    return Get.isDarkMode ? shadowColorDark : shadowColor;
  }

  static Color getTitleColor() {
    return Get.isDarkMode ? titleColorDark : titleColor;
  }

  static Color getTextColor() {
    return Get.isDarkMode ? textColorDark : textColor;
  }

  static Color getTextColor2() {
    return Get.isDarkMode ? textColorDark : textColor2;
  }

  static Color getInputColor() {
    return Get.isDarkMode ? bodyColorDark : inputFillColor;
  }

  static Color getBorderColor() {
    return Get.isDarkMode ? borderColorDark : borderColor;
  }

  // Primary Colors
  static const Color whiteColor = Color(0xFFffffff);
  static const Color blackColor = Color(0xFF000000);
  static Color primaryColor = const Color(0xFF9cce5a);
  // static Color primaryColor = const Color(0xFF9093fe);
  static const Color secondaryColor = Color(0xFF9093fe);
  static const Color successColor = Color(0xFF5fbe67);
  static const Color dangerColor = Color(0xFFFF536A);
  static const Color infoColor = Color(0xFF8fceff);
  static const Color violetColor = Color(0xFF9093fe);
  static const Color orangeColor = Color(0xFFff8254);
  static const Color warningColor = Color(0xFFffc457);

  // Backgorund Colors
  static const Color bodyColor = Color(0xFFf8f7f3);
  static const Color backgroundColor = Color(0xFFe7f1f2);
  static const Color shadowColor = Color(0xFFeeeeee);
  static const Color scaffoldColor = Color(0xFF0b1727);
  static const Color borderColor = Color(0xFFe5e5e5);
  static const Color inputFillColor = Color(0xFFf7f7f8);

  // Text Colors
  static const Color titleColor = Color(0xFF1f2d42);
  static const Color textColor = Color(0xFF5f7d95);
  static const Color textColor2 = Color(0xFFB8BCC4);
  static const Color titleColorDark = Color(0xFFf1f7f7);
  static const Color textColorDark = Color(0xFFD9E7FD);

  // dark mode
  static const Color bodyColorDark = Color(0xFF121331);
  static const Color containerColorDark = Color(0xFF1a1c41);
  static const Color shadowColorDark = Color(0x00000000);
  static const Color borderColorDark = Color(0xFF1a1c41);
  static const Color inputColorDark = Color(0xFF182E4E);
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FontSizeController extends GetxController {
  var fontContrast = 0.obs;

  double increaseValue = 2.0;
  double fontSizeMultiplierMaxLimit = 6.0;
  double fontSizeMultiplierMinLimit = 3.0;

  var fontSizeHyperLarge = 45.0.obs;
  var fontSizeExtraLarge = 23.0.obs;
  var fontSizeLarge = 18.0.obs;
  var fontSizeMedium = 15.0.obs;
  var fontSizeTiny = 12.0.obs;

  double getMaxFontSize(double originalSize) {
    return originalSize + (fontSizeMultiplierMaxLimit * 2);
  }

  double getMinFontSize(double originalSize) {
    return originalSize - (fontSizeMultiplierMinLimit * 2);
  }

  void increaseFontSize() {
    if (fontSizeHyperLarge.value < getMaxFontSize(45)) {
      fontSizeHyperLarge.value += increaseValue;
    }
    if (fontSizeExtraLarge.value < getMaxFontSize(23)) {
      fontSizeExtraLarge.value += increaseValue;
    }
    if (fontSizeLarge.value < getMaxFontSize(18)) {
      fontSizeLarge.value += increaseValue;
    }
    if (fontSizeMedium.value < getMaxFontSize(15)) {
      fontSizeMedium.value += increaseValue;
    }
    if (fontSizeTiny.value < getMaxFontSize(12)) {
      fontSizeTiny.value += increaseValue;
    }
  }

  void decreaseFontSize() {
    if (fontSizeHyperLarge.value > getMinFontSize(45)) {
      fontSizeHyperLarge.value -= increaseValue;
    }
    if (fontSizeExtraLarge.value > getMinFontSize(23)) {
      fontSizeExtraLarge.value -= increaseValue;
    }
    if (fontSizeLarge.value > getMinFontSize(18)) {
      fontSizeLarge.value -= increaseValue;
    }
    if (fontSizeMedium.value > getMinFontSize(15)) {
      fontSizeMedium.value -= increaseValue;
    }
    if (fontSizeTiny.value > getMinFontSize(12)) {
      fontSizeTiny.value -= increaseValue;
    }
  }

  void resetFontSize() {
    fontSizeHyperLarge.value = 45.0;
    fontSizeExtraLarge.value = 23.0;
    fontSizeLarge.value = 18.0;
    fontSizeMedium.value = 15.0;
    fontSizeTiny.value = 12.0;
  }

  void increaseFontContrast() {
    if (fontContrast.value < 10) {
      fontContrast.value += 1;
    }
  }
  void decreaseFontContrast() {
    if (fontContrast.value > 1) {
      fontContrast.value -= 1;
    }
  }
  void resetFontContrast() {
    fontContrast.value = 0;
  }

  FontWeight obtainContrastFromBase(FontWeight baseWeight) {
    int baseWeightValue = baseWeight.index * 100;
    int newWeightValue = baseWeightValue + (fontContrast.value * 100);
    if (newWeightValue > 900) {
      newWeightValue = 900;
    } else if (newWeightValue < 100) {
      newWeightValue = 100;
    }

    switch (newWeightValue) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }
}
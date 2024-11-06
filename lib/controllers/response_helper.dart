import 'package:travel_hour/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart' as getx;

// capitalizes the first letter of each word
String capitalizeEachWord(String input) {
  List<String> words = input.split(' ');
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] = words[i][0].toUpperCase() + words[i].substring(1);
    }
  }
  return words.join(' ');
}

changeDateFormat(dynamic time) {
  DateTime dateTime = DateTime.parse(time);
  return DateFormat('MMMM d, yyyy').format(dateTime);
}

void handleSuccessResponse(Map<String, dynamic> data) {
  getx.Get.snackbar(
    capitalizeEachWord(data['status']),
    data['messages'] ?? data['message'],
    duration: const Duration(seconds: 2),
    backgroundColor: CustomColors.getContainerColor(),
  );
}

void handleFailureResponse(Map<String, dynamic> data) {
  if (data['errors'].runtimeType.toString().toLowerCase() == "string") {
    getx.Get.snackbar(
      capitalizeEachWord(data['status']),
      data['errors'],
      duration: const Duration(seconds: 2),
      backgroundColor: CustomColors.dangerColor,
      colorText: CustomColors.whiteColor,
    );
  } else {
    getx.Get.snackbar(
      capitalizeEachWord(data['status']),
      "",
      messageText: SizedBox(
        height: 20.h,
        child: ListView.builder(
          itemCount: data['errors'].length,
          itemBuilder: (context, index) {
            TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
            return Text(
              data['errors'][index],
              style: _textStyleMedium.copyWith(color: CustomColors.whiteColor),
            );
          },
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: CustomColors.dangerColor,
      colorText: CustomColors.whiteColor,
    );
  }
}

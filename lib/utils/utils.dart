import 'package:travel_hour/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class Utils {
  static dateFormat(dynamic time) {
    DateTime dateTime = DateTime.parse(time);
    return DateFormat('d MMM, yy hh:mm a').format(dateTime);
  }

  static List<BoxShadow> defaultBoxShadow() {
    return [
      BoxShadow(
        color: CustomColors.getShadowColor(),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

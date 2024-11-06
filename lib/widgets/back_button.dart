import 'package:travel_hour/utils/app_colors.dart';
import 'package:travel_hour/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class GetBackButton extends StatelessWidget {
  const GetBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.back(),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: CustomColors.getContainerColor(),
          boxShadow: Utils.defaultBoxShadow(),
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Icon(
          Ionicons.chevron_back_outline,
          color: CustomColors.getTextColor(),
          size: 10.sp,
        ),
      ),
    );
  }
}

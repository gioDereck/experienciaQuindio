import 'package:travel_hour/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_hour/utils/utils.dart';

class ShimmerPreloader extends StatelessWidget {
  const ShimmerPreloader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CustomColors.primaryColor.withOpacity(.1),
      highlightColor: CustomColors.primaryColor.withOpacity(.2),
      child: Container(
        height: 95.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomColors.getContainerColor(),
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: Utils.defaultBoxShadow(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    return SizedBox(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/not_found.png",
              fit: BoxFit.contain,
              width: 170.w,
              height: 170.h,
            ),
            // SizedBox(height: 20.h),
            Text(
              errorMessage,
              style: _textStyleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

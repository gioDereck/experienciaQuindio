import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    required this.title,
    this.bgColor = Colors.transparent,
    this.leading,
    this.action,
  });

  final String title;
  final Color bgColor;
  final List<Widget>? leading;
  final List<Widget>? action;

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    return Container(
      color: bgColor,
      padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
      child: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(title, style: _textStyleLarge),
        elevation: 0, // Remove the shadow
        centerTitle: true,
        leading: Row(children: leading ?? []),
        actions: action,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

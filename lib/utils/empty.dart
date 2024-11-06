import 'package:flutter/material.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';

class EmptyPage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String message1;
  const EmptyPage(
      {Key? key,
      required this.icon,
      required this.message,
      required this.message1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _textStyleLarge.copyWith(
                fontWeight:
                    fontSizeController.obtainContrastFromBase(FontWeight.w500),
                color: Colors.grey[700]),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            message1,
            textAlign: TextAlign.center,
            style: _textStyleMedium.copyWith(
                fontWeight:
                    fontSizeController.obtainContrastFromBase(FontWeight.w400),
                color: Colors.grey[700]),
          )
        ],
      ),
    );
  }
}

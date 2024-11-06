import 'package:flutter/material.dart';
import '../pages/notifications.dart';
import '../services/app_service.dart';
import 'next_screen.dart';

import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';

void showinAppDialog(context, title, body) {
  FontSizeController fontSizeController = Get.find<FontSizeController>();
  TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(AppService.getNormalText(body),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: _textStyleMedium.copyWith(
              fontWeight:
                  fontSizeController.obtainContrastFromBase(FontWeight.w500),
            )),
      ),
      actions: <Widget>[
        TextButton(
            child: Text('Close', style: _textStyleMedium),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        TextButton(
            child: Text('Open', style: _textStyleMedium),
            onPressed: () {
              Navigator.of(context).pop();
              nextScreen(context, NotificationsPage());
            }),
      ],
    ),
  );
}

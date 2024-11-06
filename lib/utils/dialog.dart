import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

void openDialog(context, title, message) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

        return AlertDialog(
          content: Text(message, style: _textStyleMedium),
          title: Text(title, style: _textStyleMedium),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK', style: _textStyleMedium).tr(),
            )
          ],
        );
      });
}

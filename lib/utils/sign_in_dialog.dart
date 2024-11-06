import 'package:flutter/material.dart';
import 'package:travel_hour/pages/sign_in.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

openSignInDialog(context) {
  TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text('no sign in title', style: _textStyleMedium).tr(),
          content: Text('no sign in subtitle', style: _textStyleMedium).tr(),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  nextScreenPopup(
                      context,
                      SignInPage(
                        tag: 'popup',
                      ));
                },
                child: Text('sign in', style: _textStyleMedium).tr()),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('cancel', style: _textStyleMedium).tr())
          ],
        );
      });
}

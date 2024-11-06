import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

openNotificationPermissionDialog(BuildContext context) {
  TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('allow_notifications', style: _textStyleMedium).tr(),
            content:
                Text('need_allow_notifications', style: _textStyleMedium).tr(),
            actions: [
              TextButton(
                child: Text('close', style: _textStyleMedium).tr(),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('open settings', style: _textStyleMedium).tr(),
                onPressed: () {
                  Navigator.pop(context);
                  AppSettings.openAppSettings(
                      type: AppSettingsType.notification);
                },
              ),
            ],
          ));
}

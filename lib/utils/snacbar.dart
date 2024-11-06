import 'package:flutter/material.dart';

void openSnacbar(context, snacMessage) {
  TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

  final snackBar = SnackBar(
    backgroundColor: Colors.white,
    content: Container(
      alignment: Alignment.centerLeft,
      height: 60,
      child: Text(snacMessage,
          style: _textStyleMedium.copyWith(color: Colors.black)),
    ),
    action: SnackBarAction(
      label: 'Ok',
      textColor: Colors.blueAccent,
      onPressed: () {},
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

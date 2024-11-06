import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';

class CommentCount extends StatelessWidget {
  final String collectionName;
  final String? timestamp;
  const CommentCount(
      {Key? key, required this.collectionName, required this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .doc(timestamp)
          .snapshots(),
      builder: (context, AsyncSnapshot snap) {
        if (!snap.hasData)
          return Text(
            0.toString(),
            style: _textStyleMedium.copyWith(
                fontWeight:
                    fontSizeController.obtainContrastFromBase(FontWeight.w600),
                color: Colors.grey),
          );
        return Text(
          snap.data['comments count'].toString(),
          style: _textStyleMedium.copyWith(
              fontWeight:
                  fontSizeController.obtainContrastFromBase(FontWeight.w500),
              color: Colors.grey),
        );
      },
    );
  }
}

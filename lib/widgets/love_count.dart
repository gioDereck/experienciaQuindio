import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class LoveCount extends StatelessWidget {
  final String collectionName;
  final String? timestamp;
  const LoveCount(
      {Key? key, required this.collectionName, required this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    return Row(
      children: [
        Icon(
          Icons.favorite,
          color: Colors.grey[500],
          size: 18,
        ),
        SizedBox(
          width: 2,
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(collectionName)
              .doc(timestamp)
              .snapshots(),
          builder: (context, AsyncSnapshot snap) {
            if (!snap.hasData)
              return Text(
                0.toString(),
                style: _textStyleMedium.copyWith(
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.w600),
                    color: Colors.grey),
              );
            return Text(
              snap.data['loves'].toString(),
              style: _textStyleLarge.copyWith(
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                  color: Colors.grey),
            );
          },
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          easy.tr('people like this'),
          maxLines: 1,
          style: _textStyleTiny.copyWith(
              fontWeight:
                  fontSizeController.obtainContrastFromBase(FontWeight.w500),
              color: Colors.grey),
        )
      ],
    );
  }
}

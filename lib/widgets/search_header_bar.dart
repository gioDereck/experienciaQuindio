import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/services/navigation_service.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return InkWell(
      child: IntrinsicHeight(
        child: Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.only(right: 15, left: 15),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  tr('search', namedArgs: {'name_ia': Config().nameIa}),
                  style: _textStyleMedium.copyWith(
                    color: Colors.blueGrey[700],
                    fontWeight: fontSizeController.obtainContrastFromBase(
                      FontWeight.w500,
                    ),
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/images/icon_ia_v2.gif',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        NavigationService().navigateToIndex(7);
      },
    );
  }
}
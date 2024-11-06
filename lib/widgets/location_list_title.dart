import 'package:travel_hour/utils/app_colors.dart';
import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    Key? key,
    required this.location,
    required this.press,
  }) : super(key: key);

  final String location;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Column(
      children: [
        ListTile(
          onTap: press,
          horizontalTitleGap: 10,
          leading: Container(
            decoration: BoxDecoration(
              color: CustomColors.primaryColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(30),
            ),
            width: 36,
            height: 36,
            child: Icon(
              Icons.location_on_sharp,
              color: CustomColors.primaryColor,
              size: 18,
            ),
          ),
          title: Text(
            location,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _textStyleMedium,
          ),
        ),
      ],
    );
  }
}

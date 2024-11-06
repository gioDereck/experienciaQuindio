import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/services/app_service.dart';

class BusinessButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String url;
  final BuildContext context;

  const BusinessButton({
    Key? key,
    required this.color,
    required this.icon,
    required this.label,
    required this.url,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    return InkWell(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: color.withOpacity(0.7),
                    offset: Offset(5, 5),
                    blurRadius: 2,
                  )
                ],
              ),
              child: Icon(
                icon,
                size: 20,
              ),
            ),
            SizedBox(width: 20),
            Text(
              label,
              style: _textStyleLarge.copyWith(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ).tr(),
          ],
        ),
      ),
      onTap: () => AppService().openLink(context, url),
    );
  }
}

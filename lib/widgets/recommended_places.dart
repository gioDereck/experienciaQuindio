import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/recommanded_places_bloc.dart';
import 'package:travel_hour/pages/more_places.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';
import 'package:travel_hour/widgets/responsive_cards_layout.dart';

class RecommendedPlaces extends StatelessWidget {
  RecommendedPlaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecommandedPlacesBloc rpb =
        Provider.of<RecommandedPlacesBloc>(context);
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 15,
            top: 10,
            right: 15,
          ),
          child: Row(
            children: <Widget>[
              Text(
                'recommended places',
                style: _textStyleLarge.copyWith(
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.w600),
                    color: Colors.grey[800],
                    wordSpacing: 1,
                    letterSpacing: -0.6),
              ).tr(),
              Spacer(),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => nextScreen(
                    context,
                    MorePlacesPage(
                      title: 'recommended',
                      color: Colors.green[300],
                    )),
              )
            ],
          ),
        ),
        ResponsiveCardsLayout(
          data: rpb.data.toList(),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/blocs/other_places_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/services/drag_scroll.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'custom_cache_image.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

class OtherPlaces extends StatefulWidget {
  final String? stateName;
  final String? timestamp;
  OtherPlaces({Key? key, required this.stateName, required this.timestamp})
      : super(key: key);

  @override
  _OtherPlacesState createState() => _OtherPlacesState();
}

class _OtherPlacesState extends State<OtherPlaces> {
  @override
  void initState() {
    super.initState();
    context.read<OtherPlacesBloc>().getData(widget.stateName, widget.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OtherPlacesBloc>();
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    if (ob.data.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 0,
            top: 10,
          ),
          child: Text(
            'you may also like',
            style: _textStyleLarge.copyWith(
              fontWeight:
                  fontSizeController.obtainContrastFromBase(FontWeight.w800),
            ),
          ).tr(),
        ),
        Container(
          margin: EdgeInsets.only(top: 8, bottom: 8),
          height: 3,
          width: 100,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40)),
        ),
        ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: Container(
            height: 245,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: ob.data.length,
              itemBuilder: (BuildContext context, int index) {
                return _ItemList(
                  d: ob.data[index],
                );
              },
            ),
          ),
        )
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  final Place d;
  const _ItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        width:
            350, // Cambiado de MediaQuery.of(context).size.width * 0.38 a 350 fijo
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Hero(
              // Agregado Hero animation
              tag: 'popular${d.timestamp}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CustomCacheImage(imageUrl: d.imageUrl1),
                    // Container(
                    //   // Agregado overlay oscuro
                    //   color: Colors.black.withOpacity(0.35),
                    // ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // Sin opacidad arriba
                      Colors.transparent,
                      Colors.black
                          .withOpacity(0.9), // Opacidad en la parte inferior
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Text(
                  d.name!,
                  maxLines: 2,
                  style: _textStyleLarge.copyWith(
                      // Cambiado de _textStyleMedium a _textStyleLarge
                      color: Colors.white,
                      fontWeight: fontSizeController
                          .obtainContrastFromBase(FontWeight.w500)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(top: 15, right: 15),
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[600]!.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LineIcons.heart, size: 16, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          d.loves.toString(),
                          style: _textStyleMedium.copyWith(
                              // Cambiado de _textStyleTiny a _textStyleMedium
                              color: Colors.white),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
      onTap: () => nextScreenReplace(
          context, PlaceDetails(data: d, tag: null, itComeFromHome: false)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';

import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';

class ListCard extends StatelessWidget {
  final Place? d;
  final String tag;
  final Color? color;
  const ListCard(
      {Key? key, required this.d, required this.tag, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.bottomRight,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 15, bottom: 0),
            child: Stack(
              children: <Widget>[
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      margin: EdgeInsets.only(
                          top: 15, left: 25, right: 10, bottom: 10),
                      alignment: Alignment.topLeft,
                      // Eliminamos height fijo
                      constraints: BoxConstraints(
                        minHeight: 120, // Mantenemos altura mínima de 120
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15,
                            left: 115,
                            right: 10,
                            bottom: 15), // Añadido padding bottom
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // Permite que la columna se ajuste al contenido
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              d!.name!,
                              style: _textStyleMedium.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w600),
                              ),
                              // Removemos maxLines y overflow para permitir múltiples líneas
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Feather.map_pin,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Expanded(
                                  child: Text(
                                    d!.location!,
                                    // Permitimos que la ubicación también use múltiples líneas si es necesario
                                    style: _textStyleTiny.copyWith(
                                        fontWeight: fontSizeController
                                            .obtainContrastFromBase(
                                                FontWeight.w400),
                                        color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8, bottom: 20),
                              height: 2,
                              width: 120,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  LineIcons.heart,
                                  size: 18,
                                  color: const Color(0xFFFFD843),
                                ),
                                Text(
                                  d!.loves.toString(),
                                  style: _textStyleTiny.copyWith(
                                      color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Icon(
                                  LineIcons.commentAlt,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                Text(
                                  d!.commentsCount.toString(),
                                  style: _textStyleTiny.copyWith(
                                      color: Colors.grey[600]),
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 30,
              left: 5,
              child: Hero(
                tag:
                    'list_${d!.timestamp}', // Usar un ID único basado en el timestamp
                child: Container(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CustomCacheImage(imageUrl: d!.imageUrl1))),
              ))
        ],
      ),
      onTap: () => nextScreen(
          context, PlaceDetails(data: d, tag: tag, itComeFromHome: false)),
    );
  }
}

class ListCard1 extends StatelessWidget {
  final Place d;
  final String? tag;
  const ListCard1({Key? key, required this.d, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    return InkWell(
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.bottomRight,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Stack(
              children: <Widget>[
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      margin: EdgeInsets.only(
                          top: 5, left: 30, right: 10, bottom: 5),
                      alignment: Alignment.topLeft,
                      constraints: BoxConstraints(
                        minHeight: 150, // Mantenemos altura mínima de 150
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 30, left: 110, right: 10, bottom: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // Permite que la columna se ajuste al contenido
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              d.name!,
                              style: _textStyleMedium.copyWith(
                                  fontWeight: fontSizeController
                                      .obtainContrastFromBase(FontWeight.w600)),
                              // Removemos maxLines y overflow para permitir múltiples líneas
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Feather.map_pin,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Expanded(
                                  child: Text(
                                    d.location!,
                                    style: _textStyleTiny.copyWith(
                                        fontWeight: fontSizeController
                                            .obtainContrastFromBase(
                                                FontWeight.w400),
                                        color: Colors.grey[700]),
                                    // Removemos maxLines y overflow para permitir múltiples líneas
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8, bottom: 20),
                              height: 2,
                              width: 120,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  LineIcons.heart,
                                  size: 18,
                                  color: const Color(0xFFFFD843),
                                ),
                                Text(
                                  d.loves.toString(),
                                  style: _textStyleTiny.copyWith(
                                      color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Icon(
                                  LineIcons.commentAlt,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                Text(
                                  d.commentsCount.toString(),
                                  style: _textStyleTiny.copyWith(
                                      color: Colors.grey[600]),
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.031,
              left: 10,
              child: Hero(
                tag:
                    'listCard_${d.timestamp}', // Usar un ID único basado en el timestamp
                child: Container(
                    height: 120,
                    width: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CustomCacheImage(imageUrl: d.imageUrl1))),
              ))
        ],
      ),
      onTap: () => nextScreen(
          context, PlaceDetails(data: d, tag: tag, itComeFromHome: false)),
    );
  }
}

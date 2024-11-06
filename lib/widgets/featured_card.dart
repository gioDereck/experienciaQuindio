import 'package:flutter/material.dart';
import 'package:travel_hour/models/place.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';

class FeaturedCard extends StatelessWidget {
  final Place d;
  final double cardWidth;
  final bool isCenter;

  const FeaturedCard({
    Key? key,
    required this.d,
    required this.cardWidth,
    this.isCenter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    final _heroTag = GlobalKey().toString();

    final minusWidthImage = -10;
    final imageWidth = cardWidth -
        (MediaQuery.of(context).size.width >= 1000 ? minusWidthImage : 40);
    final infoCardWidth = imageWidth * 0.8;
    final imageHeight =
        isCenter ? 260.0 : 240.0; // Altura mayor para la tarjeta central
    final infoCardHeight = 140.0;
    final containerHeight = imageHeight + (infoCardHeight / 2);
    final leftInfoCardPosition = ((imageWidth - infoCardWidth) / 2) +
        (MediaQuery.of(context).size.width >= 1000
            ? minusWidthImage
            : MediaQuery.of(context).size.width >= 600
                ? 15
                : 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: containerHeight,
      child: InkWell(
        child: Stack(
          children: <Widget>[
            // Imagen principal con elevación condicional
            Positioned(
              top: 0,
              left: 10,
              right: 10,
              child: Hero(
                tag: 'featured_${d.timestamp}_$_heroTag',
                child: Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isCenter
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomCacheImage(imageUrl: d.imageUrl1),
                  ),
                ),
              ),
            ),
            // Info Card con elevación condicional
            Positioned(
              bottom: containerHeight - ((imageHeight + infoCardHeight / 2)),
              left: leftInfoCardPosition,
              child: Container(
                width: infoCardWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.grey[200]!.withOpacity(isCenter ? 0.8 : 0.5),
                      offset: Offset(0, 2),
                      blurRadius: isCenter ? 4 : 2,
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isCenter ? 18.0 : 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        d.name!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize:
                              fontSizeController.fontSizeLarge.value > 21.0
                                  ? 21.0
                                  : fontSizeController.fontSizeLarge.value,
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.location_on,
                              size: isCenter ? 18 : 16, color: Colors.grey),
                          Expanded(
                            child: Text(
                              d.location!,
                              style: TextStyle(
                                fontSize: fontSizeController
                                            .fontSizeMedium.value >
                                        19.0
                                    ? 19.0
                                    : fontSizeController.fontSizeMedium.value,
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w400),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      Divider(color: Colors.grey[300], height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(LineIcons.heart,
                              size: isCenter ? 20 : 18,
                              color: const Color(0xFFFFD843)),
                          Text(
                            d.loves.toString(),
                            style: TextStyle(
                              fontSize:
                                  fontSizeController.fontSizeMedium.value > 19.0
                                      ? 19.0
                                      : fontSizeController.fontSizeMedium.value,
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.w400),
                            ),
                          ),
                          SizedBox(width: 30),
                          Icon(LineIcons.commentAlt,
                              size: isCenter ? 20 : 18,
                              color: const Color(0xFFFFD843)),
                          Text(
                            d.commentsCount.toString(),
                            style: TextStyle(
                              fontSize:
                                  fontSizeController.fontSizeMedium.value > 19.0
                                      ? 19.0
                                      : fontSizeController.fontSizeMedium.value,
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.w400),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // nextScreen(
          //   context,
          //   PlaceDetails(
          //       data: d, tag: 'featured${d.timestamp}', itComeFromHome: true),
          // );
          nextScreenGoWithExtra(
            context,
            'place-details',
            {
              'data': d,
              'tag': 'featured${d.timestamp}',
              'itComeFromHome': true,
              'previous_route': 'home'
            },
          );
        },
      ),
    );
  }
}

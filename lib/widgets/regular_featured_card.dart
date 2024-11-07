import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
// import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';

class RegularFeaturedCard extends StatelessWidget {
  final dynamic d;

  const RegularFeaturedCard({
    Key? key,
    required this.d,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    final _heroTag = GlobalKey().toString();
    double width = MediaQuery.of(context).size.width;
    double maxWidth = width * 0.85;
    double imageHeight = 200.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: maxWidth,
          // No definimos altura fija aquí
          child: InkWell(
            onTap: () {
              // nextScreen(
              //     context,
              //     PlaceDetails(
              //         data: d, tag: 'featured${d.timestamp}_$_heroTag'));
              nextScreenGoNamedWithOptions(
                context,
                'place-details',
                pathParameters: {'place': d.name!},
                extra: {
                  'data': d,
                  'tag': 'featured${d.timestamp}_$_heroTag',
                  'previous_route': 'explore'
                },
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: imageHeight +
                    100, // Altura mínima para asegurar espacio para la tarjeta
              ),
              child: Stack(
                fit: StackFit.loose, // Permite que el Stack se expanda
                children: [
                  // Imagen principal
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    child: Hero(
                      tag: 'featured_${d.timestamp}_$_heroTag',
                      child: Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomCacheImage(imageUrl: d.imageUrl1)),
                      ),
                    ),
                  ),
                  // Tarjeta de información
                  Positioned(
                    top: imageHeight - 40,
                    left: maxWidth * 0.1,
                    right: maxWidth * 0.1,
                    child: IntrinsicHeight(
                      // Esto permite que la altura se ajuste al contenido
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[200]!,
                                  offset: Offset(0, 2),
                                  blurRadius: 2)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                d.name!,
                                style: TextStyle(
                                  fontSize: fontSizeController
                                              .fontSizeLarge.value >
                                          24.0
                                      ? 24.0
                                      : fontSizeController.fontSizeLarge.value,
                                  fontWeight: fontSizeController
                                      .obtainContrastFromBase(FontWeight.w600),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      d.location!,
                                      style: TextStyle(
                                        fontSize: fontSizeController
                                                    .fontSizeMedium.value >
                                                21.0
                                            ? 21.0
                                            : fontSizeController
                                                .fontSizeMedium.value,
                                        fontWeight: fontSizeController
                                            .obtainContrastFromBase(
                                                FontWeight.w400),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Divider(color: Colors.grey[300], height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(LineIcons.heart,
                                      size: 18, color: const Color(0xFFFFD843)),
                                  SizedBox(width: 4),
                                  Text(
                                    d.loves.toString(),
                                    style: TextStyle(
                                        fontSize: fontSizeController
                                                    .fontSizeMedium.value >
                                                21.0
                                            ? 21.0
                                            : fontSizeController
                                                .fontSizeMedium.value,
                                        fontWeight: fontSizeController
                                            .obtainContrastFromBase(
                                                FontWeight.w500),
                                        color: Colors.grey[700]),
                                  ),
                                  SizedBox(width: 30),
                                  Icon(LineIcons.commentAlt,
                                      size: 18, color: const Color(0xFFFFD843)),
                                  SizedBox(width: 4),
                                  Text(
                                    d.commentsCount.toString(),
                                    style: TextStyle(
                                        fontSize: fontSizeController
                                                    .fontSizeMedium.value >
                                                21.0
                                            ? 21.0
                                            : fontSizeController
                                                .fontSizeMedium.value,
                                        fontWeight: fontSizeController
                                            .obtainContrastFromBase(
                                                FontWeight.w500),
                                        color: Colors.grey[700]),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

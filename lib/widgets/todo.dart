import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import '../pages/guide.dart';

import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';

class TodoWidget extends StatelessWidget {
  final Place? placeData;
  final bool hideTitle;

  const TodoWidget({
    Key? key,
    required this.placeData,
    this.hideTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!hideTitle)
          Text(
            'todo',
            style: _textStyleLarge.copyWith(
              fontWeight:
                  fontSizeController.obtainContrastFromBase(FontWeight.w800),
            ),
          ).tr(),
        if (!hideTitle)
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        SizedBox(height: 10), // Espacio adicional si es necesario
        // Primera sección de botones (fijos)
        GridView.count(
          padding: EdgeInsets.all(0),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 1,
          childAspectRatio: 4.5,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            // Botón 1: Travel Guide (ya modificado)
            InkWell(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFF9E7EB9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  //Aqui
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 40, //Aqui
                      width: 40, //Aqui
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0xFF9D7CB9).withOpacity(0.7),
                            offset: Offset(5, 5),
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        LineIcons.car,
                        size: 20, //Aqui
                      ),
                    ),
                    SizedBox(width: 20), //Aqui
                    Text(
                      'travel guide',
                      style: _textStyleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: fontSizeController
                            .obtainContrastFromBase(FontWeight.w600),
                      ),
                    ).tr(),
                  ],
                ),
              ),
              onTap: () => nextScreen(context, GuidePage(d: placeData)),
            ),

            /*
            // Botón 2: Nearby Hotels (modificado)
            InkWell(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFF2565C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  // Modificado: Cambiado de Column a Row
                  crossAxisAlignment: CrossAxisAlignment.center, // Modificado
                  children: <Widget>[
                    Container(
                      height: 40, // Modificado
                      width: 40, // Modificado
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0xFFF2565C).withOpacity(0.7),
                            offset: Offset(5, 5),
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        LineIcons.hotel,
                        size: 20, // Modificado
                      ),
                    ),
                    SizedBox(width: 20), // Añadido espacio horizontal
                    Text(
                      'nearby hotels',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17, // Modificado
                      ),
                    ).tr(),
                  ],
                ),
              ),
              onTap: () => nextScreen(
                context,
                HotelPage(placeData: placeData),
              ),
            ),
            // Botón 3: Nearby Restaurants (modificado)
            InkWell(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD843),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  // Modificado: Cambiado de Column a Row
                  crossAxisAlignment: CrossAxisAlignment.center, // Modificado
                  children: <Widget>[
                    Container(
                      height: 40, // Modificado
                      width: 40, // Modificado
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0xFFFFD843).withOpacity(0.7),
                            offset: Offset(5, 5),
                            blurRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 20, // Modificado
                      ),
                    ),
                    SizedBox(width: 20), // Añadido espacio horizontal
                    Text(
                      'nearby restaurants',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17, // Modificado
                      ),
                    ).tr(),
                  ],
                ),
              ),
              onTap: () => nextScreen(
                context,
                RestaurantPage(placeData: placeData),
              ),
            ),
            // Botón 4: User Reviews (modificado)
            // Se agrega la opción de comentar en la vista place_details
            // InkWell(
            //   child: Container(
            //     padding: EdgeInsets.all(15),
            //     decoration: BoxDecoration(
            //       color: Color(0xFFA5CE37),
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Row(
            //       // Modificado: Cambiado de Column a Row
            //       crossAxisAlignment: CrossAxisAlignment.center, // Modificado
            //       children: <Widget>[
            //         Container(
            //           height: 40, // Modificado
            //           width: 40, // Modificado
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: Colors.white,
            //             boxShadow: <BoxShadow>[
            //               BoxShadow(
            //                 color: Color(0xFFA5CE37).withOpacity(0.7),
            //                 offset: Offset(5, 5),
            //                 blurRadius: 2,
            //               )
            //             ],
            //           ),
            //           child: Icon(
            //             LineIcons.comments,
            //             size: 20, // Modificado
            //           ),
            //         ),
            //         SizedBox(width: 20), // Añadido espacio horizontal
            //         Text(
            //           'user reviews',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.w600,
            //             fontSize: 17, // Modificado
            //           ),
            //         ).tr(),
            //       ],
            //     ),
            //   ),
            //   onTap: () => nextScreen(
            //     context,
            //     CommentsPage(
            //       collectionName: 'places',
            //       timestamp: placeData!.timestamp,
            //     ),
            //   ),
            // ),

            // Botones adicionales si existen
            ...ButtonList(placeData: placeData).buildButtonList(context)
          */
          ],
        ),
      ],
    );
  }
}

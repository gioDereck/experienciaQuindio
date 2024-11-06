import 'package:flutter/material.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/land_mark.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';

class ButtonList extends StatelessWidget {
  final Place? placeData;

  const ButtonList({Key? key, required this.placeData}) : super(key: key);

  List<Widget> buildButtonList(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    return [
      // Botón para Atracciones
      InkWell(
        child: Container(
          // margin: EdgeInsets.only(right: 10), // Espacio entre botones
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFFA5CE37), // Color para Atracciones
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            // Cambiado de Column a Row
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alineación vertical centrada
            children: <Widget>[
              Container(
                height: 40, // Modificado el alto del icono
                width: 40, // Modificado el ancho del icono
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xFFA5CE37).withOpacity(0.7),
                      offset: Offset(5, 5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.location_city,
                    size: 20), // Ajustado el tamaño del icono
              ),
              SizedBox(
                  width:
                      20), // Añadido espacio horizontal entre el icono y el texto
              Text(
                'nearby attractions',
                style: _textStyleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                ),
              ).tr(),
            ],
          ),
        ),
        onTap: () => nextScreen(
          context,
          LandmarkPage(
            placeData: placeData,
            site: 'attractions',
            radius: '30000',
            keyword: 'amusement_park',
            zoom: 9,
          ),
        ),
      ),
      // Botón para Aeropuertos
      InkWell(
        child: Container(
          // margin: EdgeInsets.only(right: 10), // Espacio entre botones
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFFFFA64D), // Color para Aeropuertos
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            // Cambiado de Column a Row
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alineación vertical centrada
            children: <Widget>[
              Container(
                height: 40, // Modificado el alto del icono
                width: 40, // Modificado el ancho del icono
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xFFFFA64D).withOpacity(0.7),
                      offset: Offset(5, 5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.airplanemode_active,
                    size: 20), // Ajustado el tamaño del icono
              ),
              SizedBox(
                  width:
                      20), // Añadido espacio horizontal entre el icono y el texto
              Text(
                'nearby airport',
                style: _textStyleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                ),
              ).tr(),
            ],
          ),
        ),
        onTap: () => nextScreen(
          context,
          LandmarkPage(
            placeData: placeData,
            site: 'airport',
            radius: '30000',
            type: 'airport',
            keyword: 'airport',
            zoom: 9,
          ),
        ),
      ),
      // Botón para Museos Cercanos
      InkWell(
        child: Container(
          // margin: EdgeInsets.only(right: 10), // Espacio entre botones
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFFB977D0), // Color para Museos
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            // Cambiado de Column a Row
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alineación vertical centrada
            children: <Widget>[
              Container(
                height: 40, // Modificado el alto del icono
                width: 40, // Modificado el ancho del icono
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xFFB977D0).withOpacity(0.7),
                      offset: Offset(5, 5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.museum,
                    size: 20), // Ajustado el tamaño del icono
              ),
              SizedBox(
                  width:
                      20), // Añadido espacio horizontal entre el icono y el texto
              Text(
                'nearby museums',
                style: _textStyleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                ),
              ).tr(),
            ],
          ),
        ),
        onTap: () => nextScreen(
          context,
          LandmarkPage(
            placeData: placeData,
            site: 'museums',
            radius: '3000',
            type: 'museums',
            keyword: 'museums',
            zoom: 13,
          ),
        ),
      ),
      // Botón para Lugares para Eventos
      InkWell(
        child: Container(
          // margin: EdgeInsets.only(right: 10), // Espacio entre botones
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFFFF9999), // Color para Eventos
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            // Cambiado de Column a Row
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alineación vertical centrada
            children: <Widget>[
              Container(
                height: 40, // Modificado el alto del icono
                width: 40, // Modificado el ancho del icono
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xFFFF9999).withOpacity(0.7),
                      offset: Offset(5, 5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child:
                    Icon(Icons.event, size: 20), // Ajustado el tamaño del icono
              ),
              SizedBox(
                  width:
                      20), // Añadido espacio horizontal entre el icono y el texto
              Text(
                'nearby events',
                style: _textStyleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                ),
              ).tr(),
            ],
          ),
        ),
        onTap: () => nextScreen(
          context,
          LandmarkPage(
            placeData: placeData,
            site: 'events',
            radius: '3000',
            type: 'event_venue',
            keyword: 'event_venue',
            zoom: 13,
          ),
        ),
      ),
      // Operadores turisticos
      InkWell(
        child: Container(
          // margin: EdgeInsets.only(right: 10), // Espacio entre botones
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFF5A7ECC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            // Cambiado de Column a Row
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alineación vertical centrada
            children: <Widget>[
              Container(
                height: 40, // Modificado el alto del icono
                width: 40, // Modificado el ancho del icono
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0xFF5A7ECC).withOpacity(0.7),
                      offset: Offset(5, 5),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child:
                    Icon(Icons.tour, size: 20), // Ajustado el tamaño del icono
              ),
              SizedBox(
                  width:
                      20), // Añadido espacio horizontal entre el icono y el texto
              Text(
                'nearby tourism',
                style: _textStyleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w600),
                ),
              ).tr(),
            ],
          ),
        ),
        onTap: () => nextScreen(
          context,
          LandmarkPage(
            placeData: placeData,
            site: 'tourism',
            radius: '3000',
            type: 'tour operators',
            keyword: 'tour operators',
            zoom: 13,
          ),
        ),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

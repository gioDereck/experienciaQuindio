import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart';

class ResponsiveCardsLayout extends StatelessWidget {
  final List<Place> data;
  const ResponsiveCardsLayout({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 750) {
          // Vista de grilla para pantallas anchas
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 10, bottom: 30, left: 15, right: 15),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: ((constraints.maxWidth - 45) / 2) / 220,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                if (data.isEmpty) return Container();
                return Container(
                  height: 220,
                  child: _ListItem(d: data[index]),
                );
              },
            ),
          );
        } else {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: ListView.separated(
              padding:
                  EdgeInsets.only(top: 10, bottom: 30, left: 15, right: 15),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (context, index) => SizedBox(height: 15),
              itemBuilder: (BuildContext context, int index) {
                if (data.isEmpty) return Container();
                return Container(
                  height: 220,
                  child: _ListItem(d: data[index]),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class _ListItem extends StatelessWidget {
  final Place d;
  const _ListItem({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    String? _currentLanguage;
    _currentLanguage = context.locale.languageCode;

    final translator = GoogleTranslator();
    Future<String>? _translatedTitle;

    String title = d.name!;
    _translatedTitle = translator
        .translate(title, from: 'auto', to: _currentLanguage)
        .then((result) => result.text)
        .catchError((error) {
      print('Translation error: $error');
      return title;
    });

    return InkWell(
      child: Stack(children: <Widget>[
        Hero(
          tag: 'recommended${d.timestamp}',
          child: Container(
              height: 220,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CustomCacheImage(imageUrl: d.imageUrl1))),
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
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              right: 15,
            ),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                // color: Colors.grey[900]!.withOpacity(0.6),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FutureBuilder<String>(
                  future: _translatedTitle,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 40,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[400]!),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        d.name!,
                        softWrap: true,
                        style: _textStyleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w600)),
                      );
                    }
                    return Text(
                      snapshot.data ?? d.name!,
                      softWrap: true,
                      style: _textStyleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.w600)),
                    );
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Feather.map_pin, size: 15, color: Colors.grey[400]),
                    Expanded(
                      child: Text(
                        d.location!,
                        style: _textStyleMedium.copyWith(
                            color: Colors.grey[400],
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.w500)),
                        softWrap: true,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ]),
      onTap: () => nextScreenGoNamedWithOptions(
        context,
        'place-details',
        pathParameters: {'place': d.name!},
        extra: {
          'data': d,
          'tag': 'recomended${d.timestamp}',
          'itComeFromHome': false,
          'previous_route': 'explore'
        },
      ),
      // nextScreen(
      //     context, PlaceDetails(data: d, tag: 'recommended${d.timestamp}', itComeFromHome: false)),
    );
  }
}

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/services/drag_scroll.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

class Featured extends StatefulWidget {
  Featured({Key? key}) : super(key: key);

  _FeaturedState createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FeaturedBloc>();
    double w = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: Container(
            height: 280,
            width: w,
            child: PageView.builder(
              controller: PageController(initialPage: 0),
              scrollDirection: Axis.horizontal,
              itemCount: fb.data.isEmpty ? 1 : fb.data.length,
              onPageChanged: (index) {
                context.read<FeaturedBloc>().setListIndex(index);
              },
              itemBuilder: (BuildContext context, int index) {
                if (fb.data.isEmpty) {
                  if (fb.hasData == false) {
                    return _EmptyContent();
                  } else {
                    return LoadingFeaturedCard();
                  }
                }
                return _FeaturedItemList(d: fb.data[index]);
              },
            ),
          ),
        ),
        SizedBox(height: 18),
        Center(
          child: DotsIndicator(
            dotsCount: fb.data.isEmpty ? 1 : fb.data.length,
            position: context.watch<FeaturedBloc>().listIndex,
            decorator: DotsDecorator(
              color: Colors.black26,
              activeColor: Theme.of(context).primaryColor,
              spacing: EdgeInsets.only(left: 6),
              size: const Size.square(5.0),
              activeSize: const Size(20.0, 4.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
          ),
        )
      ],
    );
  }
}

class _FeaturedItemList extends StatelessWidget {
  final Place d;
  const _FeaturedItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    final _heroTag = GlobalKey().toString();

    double w = MediaQuery.of(context).size.width;

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

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      width: w,
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Hero(
              tag: 'featured_${d.timestamp}_$_heroTag',
              child: Container(
                  height: 200,
                  width: w,
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomCacheImage(imageUrl: d.imageUrl1))),
            ),
            Positioned(
              width: w * 0.70,
              left: w * 0.11,
              bottom: 0,
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
                      FutureBuilder<String>(
                        future: _translatedTitle,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: _textStyleLarge.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w600),
                              ),
                            );
                          }
                          return Text(
                            snapshot.data ?? d.name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: _textStyleLarge.copyWith(
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.w600),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          Expanded(
                            child: Text(
                              d.location!,
                              style: _textStyleMedium.copyWith(
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
                              size: 18, color: const Color(0xFFFFD843)),
                          Text(
                            d.loves.toString(),
                            style: _textStyleMedium.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w500),
                                color: Colors.grey[700]),
                          ),
                          SizedBox(width: 30),
                          Icon(LineIcons.commentAlt,
                              size: 18, color: const Color(0xFFFFD843)),
                          Text(
                            d.commentsCount.toString(),
                            style: _textStyleMedium.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w500),
                                color: Colors.grey[700]),
                          ),
                          Spacer(),
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
          nextScreen(
              context,
              PlaceDetails(
                  data: d,
                  tag: 'featured_${d.timestamp}_$_heroTag',
                  itComeFromHome: false));
        },
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 220,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Text("no content", style: _textStyleMedium).tr(),
      ),
    );
  }
}

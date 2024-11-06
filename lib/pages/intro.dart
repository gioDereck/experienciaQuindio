import 'package:flutter/material.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/utils/next_screen.dart';
// import 'package:travel_hour/pages/home.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:travel_hour/widgets/scroll_arrow.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int _currentIndex = 0;

  CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    List<Widget> images = [
      IntroView(
          title: 'intro-title1',
          description: 'intro-description1',
          image: Config().introImage1),
      IntroView(
          title: 'intro-title2',
          description: 'intro-description2',
          image: Config().introImage2),
      IntroView(
          title: 'intro-title3',
          description: 'intro-description3',
          image: Config().introImage3),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            height: h * 0.80, // Manteniendo la altura
            child: Stack(
              children: [
                CarouselSlider(
                  carouselController: buttonCarouselController,
                  options: CarouselOptions(
                    height: h * 0.80,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index; // Actualiza el índice actual
                      });
                    },
                    viewportFraction: 1.0,
                  ),
                  items: images.map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: w,
                          child: item,
                        );
                      },
                    );
                  }).toList(),
                ),
                ScrollArrow(
                  icon: Icons.arrow_back_ios_new,
                  onPressed: () => buttonCarouselController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear),
                  isLeft: true,
                ),
                ScrollArrow(
                  icon: Icons.arrow_forward_ios,
                  onPressed: () => buttonCarouselController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear),
                  isLeft: false,
                ),
              ],
            ),
          ),
          // Indicadores de navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => buttonCarouselController.animateToPage(entry.key,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).primaryColor)
                        .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    minWidth: 120,
                    minHeight: 45,
                  ),
                  width: w * 0.20,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.resolveWith((states) =>
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25))),
                      minimumSize: WidgetStateProperty.all(Size(0, 45)),
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 16)),
                    ),
                    child: Text(
                      'get started',
                      style: _textStyleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.w600)),
                    ).tr(),
                    onPressed: () {
                      // nextScreenReplace(context, HomePage());
                      nextScreenGoNamed(context, 'explore');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroView extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  const IntroView(
      {Key? key,
      required this.title,
      required this.description,
      required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: h * 0.05,
          ),
          Container(
            alignment: Alignment.center,
            height: h * 0.35,
            child: Image(
              image: AssetImage(image),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            height: h * 0.02,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.06),
            child: Text(
              title,
              style: _textStyleLarge.copyWith(
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w900),
                  color: Colors.grey[800],
                  letterSpacing: -0.7,
                  wordSpacing: 1),
            ).tr(),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: h * 0.015),
            height: 3,
            width: 150,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(40)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: _textStyleLarge.copyWith(
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w500),
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                  color: Colors.grey[700]),
            ).tr(),
          ),
        ],
      ),
    );
  }
}

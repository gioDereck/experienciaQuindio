import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/widgets/featured_carousel.dart';
import 'package:travel_hour/widgets/regular_featured_slider.dart';

class Featured extends StatefulWidget {
  Featured({Key? key}) : super(key: key);

  _FeaturedState createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  late PageController _pageController;
  double viewPortFraction = 0.32;
  double? pageOffset = 0;
  bool _isInitialized = false;
  int _middleIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fb = context.read<FeaturedBloc>();
    viewPortFraction = MediaQuery.of(context).size.width >= 1000
        ? 0.32
        : MediaQuery.of(context).size.width >= 800
            ? 0.4
            : MediaQuery.of(context).size.width >= 600
                ? 0.6
                : 0.9;

    _middleIndex = fb.data.length;

    if (!_isInitialized && fb.data.isNotEmpty) {
      _pageController = PageController(
        initialPage: _middleIndex,
        viewportFraction: viewPortFraction,
      )..addListener(() {
          setState(() {
            pageOffset = _pageController.page;
          });
        });

      pageOffset = _middleIndex.toDouble();
      _isInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _ensureMiddlePosition();
        }
      });
    }
  }

  void _ensureMiddlePosition() {
    if (!_pageController.hasClients) return;
    final fb = context.read<FeaturedBloc>();
    if (fb.data.isEmpty) return;
    _pageController.jumpToPage(_middleIndex);
    pageOffset = _middleIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FeaturedBloc>();
    double width = MediaQuery.of(context).size.width;
    bool isWideScreen = width >= 600;

    double viewPortFraction = MediaQuery.of(context).size.width >= 1000
        ? 0.32 // Pantallas grandes
        : MediaQuery.of(context).size.width >= 800
            ? 0.4
            : MediaQuery.of(context).size.width >= 600
                ? 0.6 // Tablets
                : 0.9; // Móviles

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!isWideScreen)
          RegularFeaturedSlider(width: width)
        else
          FeaturedCarousel(
            viewPortFraction: viewPortFraction,
            width: width,
          ),
        SizedBox(height: 8),
        Center(
          child: DotsIndicator(
            dotsCount: fb.data.isEmpty ? 1 : fb.data.length,
            position: fb.listIndex,
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
        ),
      ],
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:travel_hour/widgets/featured_card.dart';
import 'package:easy_localization/easy_localization.dart';

class FeaturedCarousel extends StatefulWidget {
  final double viewPortFraction;
  final double width;

  const FeaturedCarousel({
    Key? key,
    required this.viewPortFraction,
    required this.width,
  }) : super(key: key);

  @override
  _FeaturedCarouselState createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late PageController _pageController;
  double? pageOffset = 0;
  bool _isInitialized = false;
  int _middleIndex = 0;

  // Constants for animations
  final double baseScale = 0.85;
  final double centerScale = 1.1;
  final double baseOpacity = 0.7;
  final double centerOpacity = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fb = context.read<FeaturedBloc>();
    _middleIndex = fb.data.length;

    if (!_isInitialized && fb.data.isNotEmpty) {
      _pageController = PageController(
        initialPage: _middleIndex,
        viewportFraction: widget.viewPortFraction,
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
    final cardWidth = widget.width * widget.viewPortFraction;
    final totalItems = fb.data.length * 3;

    if (fb.data.isEmpty) {
      return Container(
        height: 280,
        child: fb.hasData ? LoadingFeaturedCard() : _EmptyContent(),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: Container(
        height: 350,
        width: widget.width,
        child: PageView.builder(
          controller: _pageController,
          itemCount: totalItems,
          onPageChanged: (index) {
            if (!_pageController.hasClients) return;

            int actualIndex = index % fb.data.length;
            context.read<FeaturedBloc>().setListIndex(actualIndex);

            if (index >= (totalItems - fb.data.length)) {
              _pageController
                  .jumpToPage(_middleIndex + (index % fb.data.length));
            } else if (index < fb.data.length) {
              _pageController
                  .jumpToPage(_middleIndex + (index % fb.data.length));
            }
          },
          itemBuilder: (context, index) {
            if (!_pageController.hasClients || pageOffset == null) {
              return Container();
            }

            int actualIndex = index % fb.data.length;
            double relativePosition = (pageOffset! - index);

            // Calculate scale based on absolute distance from center
            double normalizedDistance = relativePosition.abs();
            double scale = baseScale;
            double opacity = baseOpacity;

            if (normalizedDistance <= 1.0) {
              // Smooth interpolation between base and center scale/opacity
              double t = 1.0 - normalizedDistance;
              scale = baseScale + (centerScale - baseScale) * t;
              opacity = baseOpacity + (centerOpacity - baseOpacity) * t;
            }

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 250),
              tween: Tween<double>(begin: scale, end: scale),
              builder: (context, double value, child) {
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: opacity,
                  child: Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: cardWidth,
                      child: FeaturedCard(
                        d: fb.data[actualIndex],
                        cardWidth: cardWidth,
                        isCenter: normalizedDistance < 0.5,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

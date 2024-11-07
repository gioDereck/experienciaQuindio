import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/blocs/recent_places_bloc.dart';
import 'package:travel_hour/models/place.dart';
import 'package:provider/provider.dart';
// import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/services/drag_scroll.dart';
import 'package:travel_hour/utils/app_colors.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_hour/services/navigation_service.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'dart:async';

class RecentPlaces extends StatefulWidget {
  RecentPlaces({Key? key}) : super(key: key);

  @override
  _RecentPlacesState createState() => _RecentPlacesState();
}

class _RecentPlacesState extends State<RecentPlaces> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  static const double tabletBreakpoint = 900;
  static const double scrollAmount = 350.0; // Para click simple
  static const double continuousScrollAmount = 50.0; // Para mantener presionado

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Para click simple
  void _scrollToOffset(bool forward) {
    if (_scrollController.hasClients) {
      final double currentOffset = _scrollController.offset;
      final double maxOffset = _scrollController.position.maxScrollExtent;
      final double targetOffset = forward
          ? (currentOffset + scrollAmount).clamp(0.0, maxOffset)
          : (currentOffset - scrollAmount).clamp(0.0, maxOffset);

      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Para mantener presionado
  void _startContinuousScroll(bool forward) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final double newOffset = _scrollController.offset +
            (forward ? continuousScrollAmount : -continuousScrollAmount);
        if (newOffset >= 0 &&
            newOffset <= _scrollController.position.maxScrollExtent) {
          _scrollController.animateTo(
            newOffset,
            duration: Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        } else {
          _stopContinuousScroll();
        }
      }
    });
  }

  void _stopContinuousScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final pb = context.watch<RecentPlacesBloc>();
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 15, top: 15, right: 10),
          child: Row(
            children: <Widget>[
              Text(
                'recently added',
                style: _textStyleLarge.copyWith(
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.bold),
                    color: Colors.grey[900],
                    wordSpacing: 1,
                    letterSpacing: -0.6),
              ).tr(),
              Spacer(),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  NavigationService().navigateToIndex(6);
                },
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > tabletBreakpoint;

              return Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: Container(
                        height: 245,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: pb.data.isEmpty ? 3 : pb.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (pb.data.isEmpty)
                              return LoadingPopularPlacesCard();
                            return _ItemList(d: pb.data[index]);
                          },
                        ),
                      ),
                    ),
                    if (isDesktop) ...[
                      Positioned(
                        left: -5,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CustomColors.primaryColor.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => _scrollToOffset(false),
                            onTapDown: (_) => _startContinuousScroll(false),
                            onTapUp: (_) => _stopContinuousScroll(),
                            onTapCancel: _stopContinuousScroll,
                            child: Container(
                              width: 40,
                              height: 40,
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -5,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CustomColors.primaryColor.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => _scrollToOffset(true),
                            onTapDown: (_) => _startContinuousScroll(true),
                            onTapUp: (_) => _stopContinuousScroll(),
                            onTapCancel: _stopContinuousScroll,
                            child: Container(
                              width: 40,
                              height: 40,
                              child: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  final Place d;
  const _ItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        width: MediaQuery.of(context).size.width > 900
            ? 350
            : MediaQuery.of(context).size.width * 0.40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Hero(
              tag: 'recent${d.timestamp}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomCacheImage(imageUrl: d.imageUrl1),
              ),
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
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Text(
                  d.name!,
                  maxLines: 2,
                  style: _textStyleMedium.copyWith(
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.w500),
                    color: Colors.white,
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
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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
                        style: _textStyleTiny.copyWith(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () => nextScreenGoWithExtra(
        context,
        'place-details',
        {
          'data': d,
          'tag': 'recent${d.timestamp}',
          'itComeFromHome': true,
          'previous_route': 'home'
        },
      ),
      // nextScreen(
      //     context,
      //     PlaceDetails(
      //         data: d, tag: 'recent${d.timestamp}', itComeFromHome: true)),
    );
  }
}

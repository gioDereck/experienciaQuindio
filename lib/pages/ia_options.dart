// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/pages/ai/ai_health/measurement_screen.dart';
import 'package:travel_hour/pages/ai/language_translation_screen.dart';
import 'package:travel_hour/pages/currency_converter.dart';
import 'package:travel_hour/pages/earn_points.dart';
import 'package:travel_hour/pages/ai/chat_screen.dart';
import 'package:travel_hour/pages/game_menu.dart';
import 'package:travel_hour/pages/itinerary/create_itinerary_screen.dart';
import 'package:travel_hour/pages/qr_list.dart';
import 'package:travel_hour/pages/quindio_map.dart';
import 'package:travel_hour/pages/saved_itinerary/saved_itineraries_screen.dart';
import 'package:travel_hour/pages/coffee_routes_list.dart';
import 'package:travel_hour/services/drag_scroll.dart';
import 'package:travel_hour/services/navigation_service.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/header.dart';
import 'package:travel_hour/widgets/transparent_modal.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/controllers/font_size_controller.dart';

class IaOptionsPage extends StatefulWidget {
  IaOptionsPage({Key? key}) : super(key: key);
  _IaOptionsPageState createState() => _IaOptionsPageState();
}

class _IaOptionsPageState extends State<IaOptionsPage>
    with AutomaticKeepAliveClientMixin {
  late List<MenuOptionData> menuOptionsData;
  bool _showModal = true;

  @override
  void initState() {
    super.initState();
    menuOptionsData = [
      MenuOptionData(
        titleKey: 'itinerary',
        descriptionKey: 'itinerary_desc',
        icon: LineIcons.route,
        backgroundColor: Color(0xFF8E44AD),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_1.png",
        onTap: CreateItineraryScreen(),
      ),
      MenuOptionData(
        titleKey: 'assistant_label',
        descriptionKey: 'chat ai desc',
        icon: LineIcons.robot,
        backgroundColor: Color(0xFF3498DB),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_2.png",
        onTap: ChatScreen(),
      ),
      MenuOptionData(
        titleKey: 'translator',
        descriptionKey: 'translator desc',
        icon: LineIcons.language,
        backgroundColor: Color(0xFF2ECC71),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_3.png",
        onTap: LanguageTranslationScreen(),
      ),
      MenuOptionData(
        titleKey: 'ai health',
        descriptionKey: 'ai health desc',
        icon: Ionicons.heart,
        backgroundColor: Color(0xFFE74C3C),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_9.png",
        onTap: MeasurementScreen(),
      ),
      MenuOptionData(
        titleKey: 'itinerary history',
        descriptionKey: 'itinerary history desc',
        icon: LineIcons.list,
        backgroundColor: Color(0xFFE74C3C),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_4.png",
        onTap: SavedItineraryScreen(),
      ),
      MenuOptionData(
        titleKey: 'currency converter',
        descriptionKey: 'currency converter desc',
        icon: LineIcons.monero,
        backgroundColor: Color(0xFFE74C3C),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_6.png",
        onTap: CurrencyConverterPage(),
      ),
      MenuOptionData(
        titleKey: 'earn points',
        descriptionKey: 'earn points desc',
        icon: Ionicons.add,
        backgroundColor: Color(0xFFE74C3C),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_7.png",
        onTap: EarnPointsPage(),
      ),
      MenuOptionData(
        titleKey: 'games',
        descriptionKey: 'games desc',
        icon: LineIcons.gamepad,
        backgroundColor: Color(0xFFE74C3C),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/ia_options/bn_5.png",
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const GamesMenuScreen(),
          //   ),
          // );
          nextScreenGoNamed(context, 'games');
        },
      ),
      MenuOptionData(
        titleKey: 'coffee routes',
        descriptionKey: 'coffee_routes desc',
        icon: LineIcons.route,
        backgroundColor: Color(0xFFE74C3C),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/coffee_routes/ruta_cafe.png",
        onTap: () {
          // CoffeeRoutesList()
          nextScreenGoNamed(context, 'coffee_routes');
        },
      ),
      MenuOptionData(
        titleKey: 'interactive map',
        descriptionKey: 'interactive map desc',
        icon: LineIcons.mapMarker,
        backgroundColor: Color.fromARGB(255, 60, 231, 165),
        imageUrl:
            "${Config().media_url}/uploads/2024/09/app/coffee_routes/ruta_cafe_2.png",
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const QuindioMap(),
          //   ),
          // );
          nextScreenGoNamed(context, 'interactive_map');
        },
      ),
      MenuOptionData(
        titleKey: 'ar_qr',
        descriptionKey: 'ar_qr desc',
        icon: Icons.flip_camera_android,
        backgroundColor: Color.fromARGB(255, 60, 168, 231),
        imageUrl: "${Config().media_url}/uploads/2024/09/app/ar_qr/ar_qr.png",
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ImmersionQRPage(),
          //   ),
          // );
          nextScreenGoNamed(context, 'ar_qr');
        },
      ),
    ];
  }

  List<MenuOption> getTranslatedOptions() {
    return menuOptionsData
        .map((data) => MenuOption(
              title: easy.tr(data.titleKey),
              description: easy.tr(data.descriptionKey),
              icon: data.icon,
              backgroundColor: data.backgroundColor,
              imageUrl: data.imageUrl,
              onTap: data.onTap,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final translatedOptions = getTranslatedOptions();

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Scaffold(
            body: Column(
              children: [
                Header(withoutSearch: true),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MenuOptionsList(options: translatedOptions),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showModal)
            TransparentImageModal(
              onClose: () => setState(() => _showModal = false),
            ),
          Positioned(
            top: 70,
            left: 15,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.9),
                child: IconButton(
                  icon: Icon(
                    LineIcons.arrowLeft,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    NavigationService().navigateToIndex(0);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class MenuOptionsList extends StatelessWidget {
  final List<MenuOption> options;

  const MenuOptionsList({
    Key? key,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWideScreen = maxWidth > 1000;
        final isLaptopScreen = maxWidth > 700;

        FontSizeController fontSizeController =
            getx.Get.find<FontSizeController>();

        final int minusFontByThis = 2;
        double cardTitleFontSize = isWideScreen
            ? fontSizeController.fontSizeLarge.value
            : isLaptopScreen
                ? fontSizeController.fontSizeMedium.value
                : fontSizeController.fontSizeExtraLarge.value;
        double cardDescriptionFontSize =
            fontSizeController.fontSizeMedium.value;

        //double firstAndSecondCardTitleFontSize = (fontSizeController.fontSizeExtraLarge.value-minusFontByThis) < 26 ? (fontSizeController.fontSizeExtraLarge.value-minusFontByThis) : 24;
        //double firstAndSecondCardDescriptionFontSize = (fontSizeController.fontSizeMedium.value-minusFontByThis) < 20 ? (fontSizeController.fontSizeMedium.value-minusFontByThis) : 18;

        cardTitleFontSize = (cardTitleFontSize - minusFontByThis) < 26
            ? (cardTitleFontSize - minusFontByThis)
            : 24;
        cardDescriptionFontSize =
            (cardDescriptionFontSize - minusFontByThis) < 18
                ? (cardDescriptionFontSize - minusFontByThis)
                : 16;

        final double sliderWidthSize =
            isLaptopScreen ? maxWidth * 0.33 : maxWidth * 0.85;

        return Column(
          children: [
            // First two options in row or column depending on screen width
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: isLaptopScreen
                  ? Row(
                      children: [
                        ...options
                            .take(2)
                            .map((option) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: option == options.take(2).first
                                          ? 8
                                          : 0,
                                      left: option == options.take(2).last
                                          ? 8
                                          : 0,
                                    ),
                                    child: OptionButton(
                                      option: option,
                                      titleFontSize: cardTitleFontSize,
                                      descriptionFontSize:
                                          cardDescriptionFontSize,
                                      width: (maxWidth / 2) - 8,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ],
                    )
                  : Column(
                      children: [
                        ...options
                            .take(2)
                            .map((option) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OptionButton(
                                          option: option,
                                          titleFontSize: cardTitleFontSize,
                                          descriptionFontSize:
                                              cardDescriptionFontSize,
                                          width: maxWidth,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
            ),

            // First horizontal slider
            if (options.length > 2)
              ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 180,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ...options
                              .skip(2)
                              .take(3)
                              .map((option) => Padding(
                                    padding: EdgeInsets.only(
                                      right:
                                          option == options.skip(2).take(4).last
                                              ? 0
                                              : 16,
                                    ),
                                    child: OptionButton(
                                      option: option,
                                      titleFontSize: cardTitleFontSize,
                                      descriptionFontSize:
                                          cardDescriptionFontSize,
                                      width: sliderWidthSize,
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Second horizontal slider
            if (options.length > 6)
              ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 180,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ...options
                              .skip(5)
                              .take(3)
                              .map((option) => Padding(
                                    padding: EdgeInsets.only(
                                      right:
                                          option == options.skip(5).take(3).last
                                              ? 0
                                              : 16,
                                    ),
                                    child: OptionButton(
                                      option: option,
                                      titleFontSize: cardTitleFontSize,
                                      descriptionFontSize:
                                          cardDescriptionFontSize,
                                      width: sliderWidthSize,
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Third horizontal slider
            if (options.length > 8)
              ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 180,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ...options
                              .skip(8)
                              .map((option) => Padding(
                                    padding: EdgeInsets.only(
                                      right: option == options.last ? 0 : 16,
                                    ),
                                    child: OptionButton(
                                      option: option,
                                      titleFontSize: cardTitleFontSize,
                                      descriptionFontSize:
                                          cardDescriptionFontSize,
                                      width: sliderWidthSize,
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class OptionButton extends StatelessWidget {
  final MenuOption option;
  final double width;
  final double titleFontSize;
  final double descriptionFontSize;

  const OptionButton({
    Key? key,
    required this.option,
    required this.width,
    required this.titleFontSize,
    required this.descriptionFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(option.imageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if (option.onTap != null) {
            if (option.onTap is Function) {
              option.onTap!();
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => option.onTap));
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    option.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      option.title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                option.description,
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  color: Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuOptionData {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final String imageUrl;
  final Color backgroundColor;
  final dynamic onTap;

  MenuOptionData({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.imageUrl,
    required this.backgroundColor,
    this.onTap,
  });
}

// Original MenuOption class remains the same
class MenuOption {
  final String title;
  final String description;
  final IconData icon;
  final String imageUrl;
  final Color backgroundColor;
  final dynamic onTap;

  MenuOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.imageUrl,
    required this.backgroundColor,
    this.onTap,
  });
}

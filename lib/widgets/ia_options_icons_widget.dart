//IAOptionsIconsWidget

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/pages/ai/ai_health/measurement_screen.dart';
import 'package:travel_hour/pages/ai/language_translation_screen.dart';
import 'package:travel_hour/pages/earn_points.dart';
import 'package:travel_hour/pages/itinerary/create_itinerary_screen.dart';
import 'package:travel_hour/pages/saved_itinerary/saved_itineraries_screen.dart';

import 'package:flutter/foundation.dart';
import 'package:travel_hour/services/app_service.dart';
import 'package:travel_hour/widgets/webView.dart';

import 'package:url_launcher/url_launcher.dart';

class IAOptionsIconsWidget extends StatefulWidget {
  const IAOptionsIconsWidget({Key? key}) : super(key: key);

  @override
  _IAOptionsIconsWidgetState createState() => _IAOptionsIconsWidgetState();
}

class _IAOptionsIconsWidgetState extends State<IAOptionsIconsWidget> {
  bool _expanded = true;
  late List<Map<String, dynamic>> _topIcons;
  late List<Map<String, dynamic>> _bottomIcons;

  @override
  void initState() {
    super.initState();

    _topIcons = [
      {
        'icon': 'assets/images/ia_icons/icon_1.png',
        'label': 'itinerary',
        'color': '0xFFFBBDC0',
        'page': CreateItineraryScreen()
      },
      {
        'icon': 'assets/images/ia_icons/icon_2.png',
        'label': 'chat ai',
        'color': '0xFFFFB973',
        'page': () async {
          const url = "https://wa.me/+573233561884";
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        }
      },
      {
        'icon': 'assets/images/ia_icons/icon_4.png',
        'label': 'translator',
        'color': '0xFFCEBEDC',
        'page': LanguageTranslationScreen()
      },
    ];
    _bottomIcons = [
      {
        'icon': 'assets/images/ia_icons/icon_3.png',
        'label': 'ai health',
        'color': '0xFF9FC6F4',
        'page': MeasurementScreen()
      },
      {
        'icon': 'assets/images/ia_icons/icon_5.png',
        'label': 'itinerary history',
        'color': '0xFFA9CE4A',
        'page': SavedItineraryScreen()
      },
      {
        'icon': 'assets/images/ia_icons/icon_6.png',
        'label': 'vr_video',
        'color': '0xFF00BFFF',
        'page': () {
          if (kIsWeb)
            AppService().openLink(context,
                "https://bigdata.igni-soft.com/experiencias-realidad-aumentada");
          else
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WebView(
                        url:
                            "https://bigdata.igni-soft.com/experiencias-realidad-aumentada")));
        }
      },
      {
        'icon': 'assets/images/ia_icons/icon_10.png',
        'label': 'ar_qr',
        'color': '0xFF00BFFF',
        'page': () {
          if (kIsWeb)
            AppService().openLink(context,
                "https://bigdata.igni-soft.com/experiencias-realidad-aumentada");
          else
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WebView(
                        url:
                            "https://bigdata.igni-soft.com/experiencias-realidad-aumentada")));
        }
      },
      {
        'icon': 'assets/images/ia_icons/icon_7.png',
        'label': 'games',
        'color': '0xFFEC407A',
        'page': () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WebView(
                      url: "https://bigdata.igni-soft.com/games")));
        }
      },
      {
        'icon': 'assets/images/ia_icons/icon_8.png',
        'label': 'currency converter',
        'color': '0xFF9E7FBB',
        'page': () {
          if (kIsWeb)
            AppService().openLink(context,
                "https://colombia.travel/es/informacion-practica/convertidor-de-moneda");
          else
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WebView(
                        url:
                            "https://colombia.travel/es/informacion-practica/convertidor-de-moneda")));
        }
      },
      {
        'icon': 'assets/images/ia_icons/icon_9.png',
        'label': 'earn points',
        'color': '0xFFFF6E61',
        'page': EarnPointsPage()
      },
      /*
      {'icon': 'assets/images/ia_icons/icon_9.png', 'label': 'earn points', 'color': '0xFFFF6E61', 'page': () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WebView(url: "https://bigdata.igni-soft.com/mapa")));
      }},
      */
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ..._topIcons.map((item) => _buildIconColumn(item)),
            _buildExpandButton(),
          ],
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: _bottomIcons.sublist(0, 3).map((item) {
                      return Column(
                        children: [
                          _buildIconColumn(item),
                          SizedBox(height: 12.0),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: _bottomIcons.sublist(3).map((item) {
                      return Column(
                        children: [
                          _buildIconColumn(item),
                          SizedBox(height: 12.0),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIconColumn(Map<String, dynamic> item) {
    TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    return InkWell(
      onTap: () {
        if (item['page'] != null) {
          if (item['page'] is Function) {
            item['page']();
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => item['page']));
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item['color'] ?? Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'], color: Colors.white),
          ),
          */
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: item['color'] != null
                  ? Color(int.parse(item['color']!))
                  : Colors.white,
              radius: 25,
              child: Image.asset(
                item['icon']!,
                fit: BoxFit.contain,
                width: 40,
                height: 40,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            item['label'],
            textAlign: TextAlign.center,
            style: _textStyleTiny,
          ).tr(),
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Icon(
              _expanded ? Icons.expand_less : Icons.more_horiz,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          _expanded ? 'Menos' : 'Más',
          style: _textStyleTiny,
        ),
      ],
    );
  }
}

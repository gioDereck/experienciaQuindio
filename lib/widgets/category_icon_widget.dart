import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/land_mark.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class CategoryIconsWidget extends StatefulWidget {
  const CategoryIconsWidget({Key? key, this.placeData}) : super(key: key);
  final Place? placeData;

  @override
  _CategoryIconsWidgetState createState() => _CategoryIconsWidgetState();
}

class _CategoryIconsWidgetState extends State<CategoryIconsWidget> {
  bool _expanded = false;
  late Place place;
  late List<Map<String, dynamic>> _topIcons;
  late List<Map<String, dynamic>> _bottomIcons;

  @override
  void initState() {
    super.initState();
    if (widget.placeData != null) {
      place = widget.placeData!;
    } else {
      throw Exception("placeData cannot be null");
    }

    // Ajuste en la lista de íconos superiores (_topIcons)
    _topIcons = [
      /*{
        'icon': LineIcons.car,
        'label': 'travel guide',
        'color': Colors.white,
        'page': GuidePage(d: place),
      },*/ // Comentado según requerimiento
      {
        'icon': Icons.attractions, // Mover "attractions" al primer lugar
        'label': 'atractions',
        'color': Colors.indigo,
        'page': LandmarkPage(
          placeData: place,
          site: 'attractions',
          radius: '3000',
          type: 'tourist_attraction',
          keyword: 'attraction',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.restaurant,
        'label': 'restaurants',
        'color': Colors.green,
        'page': LandmarkPage(
          placeData: place,
          site: 'restaurants',
          radius: '3000',
          keyword: 'restaurant',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.hotel,
        'label': 'hotels',
        'color': Colors.blue,
        'page': LandmarkPage(
          placeData: place,
          site: 'hotels',
          radius: '3000',
          type: 'hotel',
          keyword: 'hotel',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.local_gas_station,
        'label': 'gas stations',
        'color': Colors.red,
        'page': LandmarkPage(
          placeData: place,
          site: 'gas station',
          radius: '5000',
          type: 'gas_station',
          keyword: 'service_station',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.local_parking,
        'label': 'parkings',
        'color': Colors.orange,
        'page': LandmarkPage(
          placeData: place,
          site: 'parkings',
          radius: '5000',
          type: 'parkings',
          keyword: 'parkings',
          zoom: 13,
        ),
      },
    ];

    _bottomIcons = [
      {
        'icon': Icons.local_airport,
        'label': 'airports',
        'page': LandmarkPage(
          placeData: place,
          site: 'airport',
          radius: '10000',
          type: 'airport',
          keyword: 'airport',
          zoom: 10,
        ),
      },
      {
        'icon': Icons.museum_outlined,
        'label': 'nearby museums',
        'page': LandmarkPage(
          placeData: place,
          site: 'museums',
          radius: '5000',
          type: 'museums',
          keyword: 'museums',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.event,
        'label': 'nearby events',
        'page': LandmarkPage(
          placeData: place,
          site: 'events',
          radius: '5000',
          type: 'event_venue',
          keyword: 'event_venue',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.tour,
        'label': 'turistic operators',
        'page': LandmarkPage(
          placeData: place,
          site: 'tourism',
          type: 'tour_operators',
          zoom: 13,
          radius: '5000',          
          keyword: 'tour_operator|dmc|destination_management|travel_agency|tour_guide|sightseeing|day_trips|city_tours',
        ),
      },
      {
        'icon': Icons.local_hospital,
        'label': 'hospitals',
        'page': LandmarkPage(
          placeData: place,
          site: 'hospital',
          radius: '5000',
          type: 'hospital',
          keyword: 'hospital',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.atm,
        'label': 'atms',
        'page': LandmarkPage(
          placeData: place,
          site: 'atms',
          radius: '5000',
          type: 'atm',
          keyword: 'cajero',
          zoom: 13,
        ),
      },
      {
        'icon': Icons.attach_money,
        'label': 'exchange_houses',
        'page': LandmarkPage(
          placeData: place,
          site: 'exchange_houses',
          radius: '7000',
          type: 'finance',
          keyword: 'money_exchange',
          zoom: 12,
        ),
      },
      {
        'icon': Icons.shopping_bag,
        'label': 'shopping_mall',
        'page': LandmarkPage(
          placeData: place,
          site: 'shopping_mall',
          radius: '3000',
          type: 'shopping_mall',
          keyword: 'mall',
          zoom: 13,
        ),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            easy.tr('close to') + (place.name ?? 'Quindío'),
            style: _textStyleMedium.copyWith(
              fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.bold),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ..._topIcons.map((item) => _buildIconColumn(item, fontSizeController)),
            _buildExpandButton(fontSizeController),
          ],
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Si el ancho es mayor a 600px, usar 4 columnas
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: _bottomIcons.sublist(0, 2).map((item) {
                            return Column(
                              children: [
                                _buildIconColumn(item, fontSizeController),
                                SizedBox(height: 12.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: _bottomIcons.sublist(2, 4).map((item) {
                            return Column(
                              children: [
                                _buildIconColumn(item, fontSizeController),
                                SizedBox(height: 12.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: _bottomIcons.sublist(4, 6).map((item) {
                            return Column(
                              children: [
                                _buildIconColumn(item, fontSizeController),
                                SizedBox(height: 12.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: _bottomIcons.sublist(6).map((item) {
                            return Column(
                              children: [
                                _buildIconColumn(item, fontSizeController),
                                SizedBox(height: 12.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Layout original de 2 columnas para pantallas más pequeñas
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: _bottomIcons.sublist(0, 4).map((item) {
                            return Column(
                              children: [
                                _buildIconColumn(item, fontSizeController),
                                SizedBox(height: 12.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: _bottomIcons.sublist(4).map((item) {
                            return Column(
                              children: [
                                _buildIconColumn(item, fontSizeController),
                                SizedBox(height: 12.0),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          )
      ],
    );
  }

  Widget _buildIconColumn(Map<String, dynamic> item, FontSizeController fontSizeController) {
    return InkWell(
      onTap: () {
        if (item['page'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item['page']),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item['color'] ?? Colors.grey,
              shape: BoxShape.circle,
              border: item['color'] == Colors.white
                  ? Border.all(color: Colors.black, width: 2)
                  : null,
            ),
            child: Icon(
              item['icon'],
              color:
                  item['color'] == Colors.white ? Colors.black : Colors.white,
              size: item['color'] == Colors.white ? 22 : 26,
            ),
          ),
          SizedBox(height: 4),
          Text(
            item['label'],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 
              MediaQuery.of(context).size.width < 450 ? 10
              : MediaQuery.of(context).size.width < 850 ? 13 
              : fontSizeController.fontSizeTiny.value + 1),
          ).tr(),
        ],
      ),
    );
  }

  Widget _buildExpandButton(FontSizeController fontSizeController) {
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
          _expanded ? easy.tr('less') : easy.tr('more'),
          style: TextStyle(fontSize: 
              MediaQuery.of(context).size.width < 450 ? 10 
              : MediaQuery.of(context).size.width < 850 ? 13 
              : fontSizeController.fontSizeTiny.value + 1),  
        ),
      ],
    );
  }
}

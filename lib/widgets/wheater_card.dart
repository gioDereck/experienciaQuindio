import 'package:flutter/material.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

class WeatherCard extends StatefulWidget {
  final Map<String, dynamic> weatherData;

  const WeatherCard({Key? key, required this.weatherData}) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  int _selectedDayIndex = 0;
  late List<Map<String, dynamic>> weeklyWeather;

  @override
  void initState() {
    super.initState();
    weeklyWeather =
        List<Map<String, dynamic>>.from(widget.weatherData['weekly_forecast']);
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      default:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    var selectedWeather = weeklyWeather[_selectedDayIndex];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'conditions',
              style: TextStyle(
                //fontSize: 18,
                fontSize: fontSizeController.fontSizeLarge.value > 22.0
                    ? 20.0
                    : fontSizeController.fontSizeLarge.value,
                fontWeight:
                    fontSizeController.obtainContrastFromBase(FontWeight.bold),
                color: Colors.black87,
              ),
            ).tr(),
            SizedBox(height: 12),
            Row(
              children: List.generate(weeklyWeather.length, (index) {
                final weather = weeklyWeather[index];
                final date = DateTime.parse(weather['date']);
                final isSelected = index == _selectedDayIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(date)[0],
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.green : Colors.black54,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('d').format(date),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  //fontSize: 10
                                  fontSize: (fontSizeController
                                                  .fontSizeTiny.value -
                                              2) >
                                          14.0
                                      ? 12.0
                                      : (fontSizeController.fontSizeTiny.value -
                                          2),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            IntrinsicHeight(
              // Agregado para que la altura se ajuste al contenido
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedWeather['temp_day'] ?? 'N/A'}°',
                    style: TextStyle(
                      //fontSize: 23,
                      fontSize:
                          fontSizeController.fontSizeExtraLarge.value > 27.0
                              ? 25.0
                              : fontSizeController.fontSizeExtraLarge.value,
                      fontWeight: fontSizeController
                          .obtainContrastFromBase(FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Alineación superior
                          children: [
                            Icon(
                              _getWeatherIcon(selectedWeather['condition']),
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              // Cambiado de Flexible a Expanded
                              child: Text(
                                capitalizeEachWord(
                                    selectedWeather['description']),
                                style: TextStyle(
                                  //fontSize: 18
                                  fontSize: fontSizeController
                                              .fontSizeLarge.value >
                                          24.0
                                      ? 22.0
                                      : fontSizeController.fontSizeLarge.value,
                                ),
                                softWrap: true, // Permite el ajuste de línea
                                // overflow: TextOverflow.visible,  // Eliminado para permitir expansión
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4), // Espaciado adicional
                        Text(
                          'Máx.: ${selectedWeather['temp_max'] ?? 'N/A'}° Min.: ${selectedWeather['temp_min'] ?? 'N/A'}°',
                          style: TextStyle(
                              //fontSize: 15,
                              fontSize:
                                  fontSizeController.fontSizeMedium.value > 19.0
                                      ? 17.0
                                      : fontSizeController.fontSizeMedium.value,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop, size: 16, color: Colors.blue),
                          Text(
                            '${selectedWeather['humidity'] ?? 'N/A'}%',
                            style: TextStyle(
                                //fontSize: 15,
                                fontSize: fontSizeController
                                            .fontSizeMedium.value >
                                        19.0
                                    ? 17.0
                                    : fontSizeController.fontSizeMedium.value,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                      Text(
                        selectedWeather['sunrise'] ?? 'N/A',
                        style: TextStyle(
                            //fontSize: 15,
                            fontSize:
                                fontSizeController.fontSizeMedium.value > 19.0
                                    ? 17.0
                                    : fontSizeController.fontSizeMedium.value,
                            color: Colors.black54),
                      ),
                      Text(
                        selectedWeather['sunset'] ?? 'N/A',
                        style: TextStyle(
                            //fontSize: 15,
                            fontSize:
                                fontSizeController.fontSizeMedium.value > 19.0
                                    ? 17.0
                                    : fontSizeController.fontSizeMedium.value,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

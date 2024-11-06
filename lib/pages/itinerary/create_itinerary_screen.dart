import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/controllers/itinerary/itinerary_controller.dart';
import 'package:travel_hour/models/itinerary/travel_companion.dart';
import 'package:travel_hour/models/itinerary/travel_preference.dart';
import 'package:travel_hour/models/itinerary/trip_budget.dart';
import 'package:travel_hour/pages/itinerary/itinerary_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para la conversión JSON
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/config/config.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class ItineraryData {
  String place = '';
  String startDate = '';
  String endDate = '';
  String travelPartner = '';
  String tripBudget = '';
  String transport = '';
  List<String> travelPreferences = [];
}

// Vista principal para controlar los 5 pasos
class CreateItineraryScreen extends StatefulWidget {
  const CreateItineraryScreen({Key? key}) : super(key: key);

  @override
  _CreateItineraryScreenState createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  ItineraryData itineraryData = ItineraryData();
  bool canGoNextStep = false;

  // Definir los widgets para los 5 pasos
  Widget _buildStep1() => TourPlaceScreen(
        itineraryData: itineraryData,
        onValidityChanged: (isValid) {
          setState(() {
            canGoNextStep = isValid;
          });
        },
      );
  Widget _buildStep2() => TourTimeScreen(
        itineraryData: itineraryData,
        onValidityChanged: (isValid) {
          setState(() {
            canGoNextStep = isValid;
          });
        },
      );
  Widget _buildStep3() => TourCompanionScreen(
        itineraryData: itineraryData,
        onValidityChanged: (isValid) {
          setState(() {
            canGoNextStep = isValid;
          });
        },
      );
  Widget _buildStep4() => TourBudgetScreen(
        itineraryData: itineraryData,
        onValidityChanged: (isValid) {
          setState(() {
            canGoNextStep = isValid;
          });
        },
      );
  Widget _buildStep5() => TourPreferencesScreen(
        itineraryData: itineraryData,
        onValidityChanged: (isValid) {
          setState(() {
            canGoNextStep = isValid;
          });
        },
      );

  // Método para avanzar al siguiente paso
  Future<void> _nextStep([String? language]) async {
    setState(() {
      canGoNextStep = false;
    });

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Iniciar estado de carga
      setState(() {
        _isLoading = true;
      });
      // Imprimir los datos recolectados
      /*
      print('Place: ${itineraryData.place}');
      print('Start Date: ${itineraryData.startDate}');
      print('End Date: ${itineraryData.endDate}');
      print('Travel Partner: ${itineraryData.travelPartner}');
      print('Trip Budget: ${itineraryData.tripBudget}');
      print('Transport: ${itineraryData.transport}');
      print('Travel Preferences: ${itineraryData.travelPreferences}');
      */

      // Lógica de envío HTTP
      try {
        final response = await sendTripExploreRequest(
            itineraryData, 1, language); // 1 es el índice del idioma
        // print('Respuesta del servidor: ${response}');
      } catch (e) {
        print('Error en la petición: $e');
      }

      // Terminar estado de carga y navegar
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> sendTripExploreRequest(
      ItineraryData itineraryData, int languageIndex, String? language) async {
    String url = '${Config().url}/api/trip-explore';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer 104|tERTv6JWIjAWFRuhf6iBc4rokKdmq35kStO7kpsib114af9d',
    };

    String travelPreferencesString = itineraryData.travelPreferences.join(',');

    Map<String, dynamic> body = {
      'language': language == 'en'
          ? 'english'
          : language == 'es'
              ? 'spanish'
              : 'french',
      'place': itineraryData.place,
      'start_date': itineraryData.startDate,
      'end_date': itineraryData.endDate,
      'travelPartner': itineraryData.travelPartner,
      'tripBudget': itineraryData.tripBudget,
      'transport': itineraryData.transport,
      'travelPreference': travelPreferencesString
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        //print(response.body);
        // Navegar a la pantalla ItineraryScreen
        // dynamic data = await response.body;
        // data['language'] = 'spanish';
        // data['place'] = itineraryData.place;
        // data['start_date'] = itineraryData.startDate;
        // data['end_date'] = itineraryData.endDate;
        // data['travelPartner'] = itineraryData.travelPartner;
        // data['tripBudget'] = itineraryData.tripBudget;
        // data['travelPreference'] = travelPreferencesString;
        // Decode the response body
        Map<String, dynamic> data =
            jsonDecode(response.body); // Ensure data is a Map
        // Add additional properties
        data['language'] = language == 'en'
            ? 'english'
            : language == 'es'
                ? 'spanish'
                : 'french';
        data['place'] = itineraryData.place;
        data['start_date'] = itineraryData.startDate;
        data['end_date'] = itineraryData.endDate;
        data['travelPartner'] = itineraryData.travelPartner;
        data['tripBudget'] = itineraryData.tripBudget;
        data['transport'] = itineraryData.transport;
        data['travelPreference'] = travelPreferencesString;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ItineraryScreen(
                    itineraryData: data,
                    translatedDescription: data['message']['ai_response'],
                    translatedBudget: data['tripBudget'],
                    isCreateItinerary: true,
                  )),
          (Route<dynamic> route) => false,
        );
        // return response.body;
      } else {
        print('Error en la petición: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al enviar la solicitud: $e');
      return null;
    }
    return null;
  }

  // Método para retroceder al paso anterior
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    String language = context.locale.languageCode;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Encabezado personalizado con barra de progreso y botón de retroceso
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
            child: Row(
              children: [
                // Botón de retroceso
                GestureDetector(
                  onTap: _previousStep,
                  child: MouseRegion(
                    cursor:
                        SystemMouseCursors.click, // Cambia el cursor a pointer
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Barra de progreso personalizada
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: (_currentStep + 1) / 5,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Contenido de cada paso
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
              ],
            ),
          ),
          // Botón de continuar ajustado
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canGoNextStep ? () => _nextStep(language) : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor:
                      canGoNextStep ? Color(0xFFA2DB57) : Colors.grey,
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        _currentStep == 4
                            ? easy.tr("create_itinerary")
                            : easy.tr("continue"),
                        style: _textStyleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.bold),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Paso 1: Destino
class TourPlaceScreen extends StatefulWidget {
  final ItineraryData itineraryData;
  final Function(bool) onValidityChanged;
  const TourPlaceScreen({
    Key? key,
    required this.itineraryData,
    required this.onValidityChanged,
  }) : super(key: key);

  @override
  _TourPlaceScreenState createState() => _TourPlaceScreenState();
}

class _TourPlaceScreenState extends State<TourPlaceScreen> {
  List<String> cities = [];
  List<String> transportModes = [];
  bool isLoading = true;
  String? selectedCity;
  String? selectedTransport;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch cities
      final citiesResponse = await http.get(
        Uri.parse('https://conect-quin-ia.igni-soft.com/api/quidio/cities'),
      );

      // Fetch transport modes
      final transportResponse = await http.get(
        Uri.parse('https://conect-quin-ia.igni-soft.com/api/quidio/transport'),
      );

      if (citiesResponse.statusCode == 200 &&
          transportResponse.statusCode == 200) {
        final citiesData = json.decode(citiesResponse.body);
        final transportData = json.decode(transportResponse.body);

        setState(() {
          cities = List<String>.from(citiesData['data']);
          transportModes = List<String>.from(transportData['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: easy.tr("where you want to go"),
                          style: _textStyleLarge.copyWith(
                            fontWeight: fontSizeController
                                .obtainContrastFromBase(FontWeight.bold),
                          ),
                        ),
                        TextSpan(
                          text: ' ✈️',
                          style: TextStyle(
                            fontFamily: 'NotoColorEmoji',
                            fontSize: _textStyleLarge.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "tell_us_your_destiny",
              style: _textStyleMedium.copyWith(
                color: Colors.grey,
              ),
            ).tr(),
            const SizedBox(height: 30),
            // City Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedCity,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon:
                            const Icon(Icons.location_city, color: Colors.grey),
                        hintText: easy.tr("Select destination"),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue;
                          widget.itineraryData.place = newValue ?? '';
                          widget.onValidityChanged(
                              widget.itineraryData.place.isNotEmpty &&
                                  widget.itineraryData.transport.isNotEmpty);
                        });
                      },
                    ),
            ),
            const SizedBox(height: 20),
            // Transport Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedTransport,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon:
                            const Icon(Icons.directions, color: Colors.grey),
                        hintText: easy.tr("Select transport"),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      items: transportModes.map((String transport) {
                        return DropdownMenuItem<String>(
                          value: easy.tr(transport),
                          child: Text(transport).tr(),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          //print(newValue);
                          selectedTransport = newValue;
                          widget.itineraryData.transport = newValue ?? '';
                          widget.onValidityChanged(
                              widget.itineraryData.place.isNotEmpty &&
                                  widget.itineraryData.transport.isNotEmpty);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Paso 2: Calendario
class TourTimeScreen extends StatefulWidget {
  final ItineraryData itineraryData;
  final Function(bool) onValidityChanged;
  const TourTimeScreen({
    Key? key,
    required this.itineraryData,
    required this.onValidityChanged,
  }) : super(key: key);

  @override
  _TourTimeScreenState createState() => _TourTimeScreenState();
}

class _TourTimeScreenState extends State<TourTimeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              easy.tr("when_you_want_to_go") + ' \u{1F4C5}',
              style: _textStyleLarge.copyWith(
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(
              "choose_date",
              style: _textStyleMedium.copyWith(color: Colors.grey),
            ).tr(),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(2030, 12, 31),
                locale: context.locale.languageCode,
                focusedDay: _focusedDay,
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: CalendarFormat.month,
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    widget.onValidityChanged(false);
                    if (_rangeStart != null && _rangeEnd != null) {
                      _rangeStart = selectedDay;
                      _rangeEnd = null;
                    } else if (_rangeStart == null) {
                      _rangeStart = selectedDay;
                    } else if (_rangeEnd != null) {
                    } else {
                      _rangeEnd = selectedDay;
                      if (_rangeStart != null && _rangeEnd != null) {
                        widget.itineraryData.startDate =
                            _rangeStart!.toIso8601String().split('T')[0];
                        widget.itineraryData.endDate =
                            _rangeEnd!.toIso8601String().split('T')[0];
                      }
                    }
                    _focusedDay = focusedDay;
                  });
                },
                onRangeSelected: (start, end, focusedDay) {
                  setState(() {
                    _rangeStart = start;
                    _rangeEnd = end;
                    _focusedDay = focusedDay;
                    if (start != null && end != null) {
                      widget.onValidityChanged(true);
                      widget.itineraryData.startDate =
                          start.toIso8601String().split('T')[0];
                      widget.itineraryData.endDate =
                          end.toIso8601String().split('T')[0];
                    } else {
                      widget.onValidityChanged(false);
                    }
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  rangeStartDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  withinRangeDecoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Paso 3: Quién va
class TourCompanionScreen extends StatefulWidget {
  final ItineraryData itineraryData;
  final Function(bool) onValidityChanged;

  const TourCompanionScreen({
    Key? key,
    required this.itineraryData,
    required this.onValidityChanged, // Añadir al constructor
  }) : super(key: key);

  @override
  _TourCompanionScreenState createState() => _TourCompanionScreenState();
}

class _TourCompanionScreenState extends State<TourCompanionScreen> {
  String? _selectedOption;
  List<TravelCompanion> _companions = [];
  final translator = GoogleTranslator();
  Map<String, Future<String>> _translatedTitles = {};
  Map<String, Future<String>> _translatedSubtitles = {};

  @override
  void initState() {
    super.initState();
    _loadCompanions();
  }

  void _loadCompanions() async {
    try {
      final data = await ItineraryController().fetchTourCompanion();
      setState(() {
        _companions = data
            .map<TravelCompanion>((item) => TravelCompanion.fromJson(item))
            .toList();
      });
    } catch (e) {
      print("Error loading companions: $e");
    }
  }

  void _initializeTranslations(String title, String subtitle, String id) {
    if (_translatedTitles[id] == null) {
      _translatedTitles[id] = translator
          .translate(title, from: 'es', to: context.locale.languageCode)
          .then((result) => result.text)
          .catchError((error) {
        print('Translation error for title: $error');
        return title;
      });
    }
    if (_translatedSubtitles[id] == null) {
      _translatedSubtitles[id] = translator
          .translate(subtitle, from: 'es', to: context.locale.languageCode)
          .then((result) => result.text)
          .catchError((error) {
        print('Translation error for subtitle: $error');
        return subtitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  easy.tr("who_goes"),
                  style: _textStyleLarge.copyWith(
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.bold),
                  ),
                ),
                Text(
                  ' 🤷',
                  style: TextStyle(
                    fontFamily: 'NotoColorEmoji',
                    fontSize: _textStyleLarge.fontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "start_selecting",
              style: _textStyleMedium.copyWith(color: Colors.grey),
            ).tr(),
            const SizedBox(height: 30),
            if (_companions.isNotEmpty)
              Column(
                children: _companions.map((companion) {
                  _initializeTranslations(companion.name, companion.description,
                      companion.id.toString());
                  return _buildOption(
                    companion.name,
                    companion.description,
                    companion.image,
                    companion.id.toString(),
                  );
                }).toList(),
              )
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      String title, String subtitle, String imageUrl, String value) {
    final isSelected = _selectedOption == value;

    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = value;
          widget.itineraryData.travelPartner = title;
          widget.onValidityChanged(true);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FutureBuilder<String>(
                        future: _translatedTitles[value],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              height: 20,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[400]!),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Text(
                            snapshot.data ?? title,
                            style: _textStyleMedium.copyWith(
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.bold),
                              color: isSelected ? Colors.green : Colors.black,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Image.network(
                        imageUrl,
                        height: 24,
                        width: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  FutureBuilder<String>(
                    future: _translatedSubtitles[value],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 20,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[400]!),
                              ),
                            ),
                          ),
                        );
                      }
                      return Text(
                        snapshot.data ?? subtitle,
                        style: _textStyleMedium.copyWith(
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Paso 4: Presupuesto
class TourBudgetScreen extends StatefulWidget {
  final ItineraryData itineraryData;
  final Function(bool) onValidityChanged;

  const TourBudgetScreen({
    Key? key,
    required this.itineraryData,
    required this.onValidityChanged,
  }) : super(key: key);

  @override
  _TourBudgetScreenState createState() => _TourBudgetScreenState();
}

class _TourBudgetScreenState extends State<TourBudgetScreen> {
  String? _selectedOption;
  List<TripBudget> _budgets = [];

  final translator = GoogleTranslator();
  Map<String, Future<String>> _translatedTitles = {};
  Map<String, Future<String>> _translatedSubtitles = {};

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  // Agregar método para inicializar las traducciones
  void _initializeTranslations(String title, String subtitle, String id) {
    if (_translatedTitles[id] == null) {
      _translatedTitles[id] = translator
          .translate(title, from: 'es', to: context.locale.languageCode)
          .then((result) => result.text)
          .catchError((error) {
        print('Translation error for title: $error');
        return title;
      });
    }
    if (_translatedSubtitles[id] == null) {
      _translatedSubtitles[id] = translator
          .translate(subtitle, from: 'es', to: context.locale.languageCode)
          .then((result) => result.text)
          .catchError((error) {
        print('Translation error for subtitle: $error');
        return subtitle;
      });
    }
  }

  // Método para cargar el presupuesto desde el controlador
  void _loadBudgetData() async {
    try {
      final data = await ItineraryController().fetchTourBudget();
      setState(() {
        _budgets =
            data.map<TripBudget>((item) => TripBudget.fromJson(item)).toList();
      });
    } catch (e) {
      print("Error loading budget data: $e");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              easy.tr("choose_your_budget") + "\u{1F4B0}",
              style: _textStyleLarge.copyWith(
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(
              "tell_us_your_budget",
              style: _textStyleMedium.copyWith(color: Colors.grey),
            ).tr(),
            const SizedBox(height: 30),
            // Si hay datos, los mostramos
            if (_budgets.isNotEmpty)
              Column(
                children: _budgets.map((budget) {
                  _initializeTranslations(
                      budget.name, budget.description, budget.id.toString());
                  return _buildOption(
                    budget.name,
                    budget.description,
                    budget.image,
                    budget.id.toString(),
                  );
                }).toList(),
              )
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  // Método para construir cada opción
  Widget _buildOption(
      String title, String subtitle, String imageUrl, String value) {
    final isSelected = _selectedOption == value;

    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = value;
          widget.itineraryData.tripBudget = title;
          widget.onValidityChanged(true);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        imageUrl,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: _translatedTitles[value],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              height: 20,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[400]!),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Text(
                            snapshot.data ?? title,
                            style: _textStyleMedium.copyWith(
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.bold),
                              color: isSelected ? Colors.green : Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  FutureBuilder<String>(
                    future: _translatedSubtitles[value],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 20,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[400]!),
                              ),
                            ),
                          ),
                        );
                      }
                      return Text(
                        snapshot.data ?? subtitle,
                        style: _textStyleMedium.copyWith(
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Paso 5: Preferencias
class TourPreferencesScreen extends StatefulWidget {
  final ItineraryData itineraryData;
  final Function(bool) onValidityChanged;

  const TourPreferencesScreen({
    Key? key,
    required this.itineraryData,
    required this.onValidityChanged,
  }) : super(key: key);

  @override
  _TourPreferencesScreenState createState() => _TourPreferencesScreenState();
}

class _TourPreferencesScreenState extends State<TourPreferencesScreen> {
  List<TravelPreference> _preferences = [];

  // Agregar estas variables para las traducciones
  final translator = GoogleTranslator();
  Map<String, Future<String>> _translatedNames = {};

  @override
  void initState() {
    super.initState();
    _loadPreferencesData();
  }

  // Agregar método para inicializar las traducciones
  void _initializeTranslations(String name, String id) {
    if (_translatedNames[id] == null) {
      _translatedNames[id] = translator
          .translate(name, from: 'es', to: context.locale.languageCode)
          .then((result) => result.text)
          .catchError((error) {
        print('Translation error for name: $error');
        return name;
      });
    }
  }

  // Método para cargar las preferencias desde el controlador
  void _loadPreferencesData() async {
    try {
      final data = await ItineraryController().fetchTourPreference();
      setState(() {
        _preferences = data
            .map<TravelPreference>((item) => TravelPreference.fromJson(item))
            .toList();
      });
    } catch (e) {
      print("Error loading preferences data: $e");
    }
  }

  // El resto del código se mantiene igual hasta el build donde se mapean las preferencias
  @override
  Widget build(BuildContext context) {
    final selectedPreferences = widget.itineraryData.travelPreferences;
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "travel_preferences",
              style: _textStyleLarge.copyWith(
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.bold)),
            ).tr(),
            const SizedBox(height: 10),
            Text(
              "tell_us_your_preferences",
              style: _textStyleMedium.copyWith(color: Colors.grey),
            ).tr(),
            const SizedBox(height: 20),
            if (_preferences.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _preferences.map((preference) {
                  _initializeTranslations(
                      preference.name, preference.id.toString());
                  return _buildPreferenceOption(
                    preference.name,
                    preference.image,
                    preference.id.toString(),
                  );
                }).toList(),
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            if (selectedPreferences.length == 5)
              Text(
                "select_five_preferences",
                style: _textStyleMedium.copyWith(color: Colors.green),
              ).tr(),
          ],
        ),
      ),
    );
  }

  // Modificar el método _buildPreferenceOption para usar FutureBuilder
  Widget _buildPreferenceOption(String name, String imageUrl, String value) {
    final isSelected = widget.itineraryData.travelPreferences.contains(name);

    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.itineraryData.travelPreferences.length > 1) {
            widget.onValidityChanged(true);
          } else {
            widget.onValidityChanged(false);
          }
          if (isSelected) {
            widget.itineraryData.travelPreferences.remove(name);
          } else if (widget.itineraryData.travelPreferences.length < 5) {
            widget.itineraryData.travelPreferences.add(name);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imageUrl,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 10),
            FutureBuilder<String>(
              future: _translatedNames[value],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 20,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                        ),
                      ),
                    ),
                  );
                }
                return Text(
                  snapshot.data ?? name,
                  style: _textStyleMedium.copyWith(
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.bold),
                    color: isSelected ? Colors.green : Colors.black,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

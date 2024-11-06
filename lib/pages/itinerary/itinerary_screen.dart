import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/controllers/itinerary/trip_explore_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/pages/ia_options.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:translator/translator.dart';

class ItineraryScreen extends StatefulWidget {
  final Map<String, dynamic> itineraryData;
  final String translatedDescription;
  final String translatedBudget;
  final isCreateItinerary;

  const ItineraryScreen(
      {Key? key,
      required this.itineraryData,
      required this.translatedDescription,
      required this.translatedBudget,
      required this.isCreateItinerary})
      : super(key: key);

  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  bool isEditing = false;
  bool editTheContent = false;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _reminderMsgController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  late TripExploreController controller = getx.Get.put(TripExploreController());

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.translatedDescription;
  }

  Future<void> _updateItinerary({required bool withReminder}) async {
    String apiUrl = '${Config().url}/api/trip-explore/save';
    final String authToken =
        '104|tERTv6JWIjAWFRuhf6iBc4rokKdmq35kStO7kpsib114af9d';

    try {
      Uri uri = Uri.parse(apiUrl);
      /*
      print(uri);
      print("itinerary_screen.dart");
      print(widget.itineraryData['id'] ?? widget.itineraryData['message']['id']);
      print("_descriptionController");
      print(_descriptionController.text);
      print("withReminder");
      print(withReminder ? _dateController.text : null);
      print("_reminderMsgController.text");
      print(_reminderMsgController.text);
      */

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'id': widget.itineraryData['id'] ??
              widget.itineraryData['message']['id'],
          'itinerary': _descriptionController.text,
          'reminder_date': withReminder ? _dateController.text : null,
          'reminder_msg': _reminderMsgController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'].toLowerCase() == 'success') {
          //print('Itinerario actualizado correctamente.');
        } else {
          throw Exception('Error: ${data['message']}');
        }
      } else {
        throw Exception('Error al actualizar el itinerario.');
      }
    } catch (e) {
      print('Error al actualizar el itinerario: $e');
    }
  }

  void _showSaveModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(20),
          backgroundColor: Color(0xFFF1F8E9),
          surfaceTintColor: Colors.transparent,
          title: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF66BB6A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    'set a reminder',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ).tr(),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _reminderMsgController,
                  decoration: InputDecoration(
                    hintText: easy.tr('note'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: easy.tr('select time'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _dateController.text =
                              '${pickedDate.year}-${pickedDate.month}-${pickedDate.day} ${pickedTime.hour}:${pickedTime.minute}';
                        });
                      }
                    }
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_reminderMsgController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('required field').tr(),
                                content: Text('note cant be empty').tr(),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          _updateItinerary(withReminder: false);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                        margin: EdgeInsets.only(right: 10),
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color(0xFFBBDEFB),
                        ),
                        child: Center(
                          child: Text(
                            'save without reminder',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ).tr(),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_reminderMsgController.text.isEmpty ||
                            _dateController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('required fields').tr(),
                                content: Text('all fields').tr(),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          _updateItinerary(withReminder: true);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                        margin: EdgeInsets.only(right: 10),
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color(0xFF66BB6A),
                        ),
                        child: Center(
                          child: Text(
                            'save with reminder',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ).tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    final translator = GoogleTranslator();
    Future<String>? _translatedPreferences;
    Future<String>? _translatedPartners;

    String preferences = widget.itineraryData['trip_request'] != null
        ? widget.itineraryData['trip_request']['travelPreference']
        : widget.itineraryData['travelPreference'];
    _translatedPreferences = translator
        .translate(preferences, from: 'es', to: context.locale.languageCode)
        .then((result) => result.text)
        .catchError((error) {
      print('Translation error: $error');
      return preferences;
    });

    String partners = widget.itineraryData['trip_request'] != null
        ? widget.itineraryData['trip_request']['travelPartner']
        : widget.itineraryData['travelPartner'];
    _translatedPartners = translator
        .translate(partners, from: 'es', to: context.locale.languageCode)
        .then((result) => result.text)
        .catchError((error) {
      print('Translation error: $error');
      return partners;
    });

    //print(widget.itineraryData);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Imagen destacada
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/destination/destination_${Random().nextInt(12)}.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Botones flotantes (Compartir, Editar, Guardar)
                Positioned(
                  top: 50,
                  left: 10,
                  child: SafeArea(
                    child: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.9),
                      child: IconButton(
                        icon: Icon(
                          LineIcons.arrowLeft,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (editTheContent) {
                            await controller.refreshAllData();
                          }
                          if (widget.isCreateItinerary) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => IaOptionsPage()),
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            Navigator.pop(context, editTheContent);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 10,
                  child: Row(
                    children: [
                      // WhatsApp Icon Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: IconButton(
                            icon: Icon(
                              Ionicons.logo_whatsapp,
                              color: Colors.white,
                              size: 17,
                            ),
                            onPressed: () async {
                              final message = _descriptionController.text;
                              if (message.isNotEmpty) {
                                final url = 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}';

                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Error'),
                                        content:
                                            Text('No se puede abrir WhatsApp.'),
                                        actions: [
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('No se puede compartir'),
                                      content: Text(
                                          'No hay información para compartir.'),
                                      actions: [
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Botón de Editar|
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: IconButton(
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              // Acción para editar o actualizar
                              if (isEditing) {
                                if (_descriptionController.text.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('required field').tr(),
                                        content:
                                            Text('description cant be empty')
                                                .tr(),
                                        actions: [
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  _updateItinerary(withReminder: false);
                                  setState(() {
                                    editTheContent = true;
                                    isEditing = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),

                      // Boton de Recordatorio
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _showSaveModal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Fechas del itinerario
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                            (widget.itineraryData['trip_request'] != null
                                ? formatDate(
                                    widget.itineraryData['trip_request']
                                        ['start_date'],
                                    widget.itineraryData['trip_request']
                                        ['end_date'])
                                : formatDate(widget.itineraryData['start_date'],
                                    widget.itineraryData['end_date'])),
                            style:
                                _textStyleMedium.copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del destino
                  Text(
                    (widget.itineraryData['trip_request'] != null
                        ? widget.itineraryData['trip_request']['place']
                        : widget.itineraryData['place']),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Preferencias y detalles del itinerario
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _translatedPreferences,
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
                                preferences,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: _textStyleMedium.copyWith(
                                    color: Colors.grey[600]),
                              );
                            }
                            return Text(
                              snapshot.data ?? preferences,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: _textStyleMedium.copyWith(
                                  color: Colors.grey[600]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(widget.translatedBudget,
                          style: _textStyleMedium.copyWith(
                              color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.purple),
                      SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: _translatedPartners,
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
                              partners,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: _textStyleMedium.copyWith(
                                  color: Colors.grey[600]),
                            );
                          }
                          return Text(
                            snapshot.data ?? partners,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: _textStyleMedium.copyWith(
                                color: Colors.grey[600]),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Descripción del itinerario
                  isEditing
                      ? TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: easy.tr('itinerary description'),
                          ),
                        )
                      : Text(
                          _descriptionController.text,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String startDateStr, String endDateStr) {
    DateTime startDate = DateTime.parse(startDateStr);
    DateTime endDate = DateTime.parse(endDateStr);
    String language = context.locale.languageCode;

    DateFormat formatter = DateFormat('MMMM d, yyyy', language);
    String formattedStartDate = formatter.format(startDate);
    String formattedEndDate = formatter.format(endDate);

    return "${capitalize(formattedStartDate)} — ${capitalize(formattedEndDate)}";
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

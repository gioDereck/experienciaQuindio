import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/controllers/itinerary/trip_explore_controller.dart';
import 'package:travel_hour/pages/itinerary/itinerary_screen.dart';
import 'package:travel_hour/services/app_service.dart';
import 'dart:math';
import 'package:travel_hour/widgets/contact_buttons.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';

class SavedItineraryScreen extends StatefulWidget {
  const SavedItineraryScreen({Key? key}) : super(key: key);
  @override
  _SavedItineraryScreen createState() => _SavedItineraryScreen();
}

class _SavedItineraryScreen extends State<SavedItineraryScreen> {
  late List<TripModel> itineraries = [];
  late TripExploreController controller = Get.put(TripExploreController());
  bool isLoading = true;
  var data = null;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    if (controller.tripList.isEmpty) {
      _loadSavedTrip();
    }
  }

  void _loadSavedTrip() async {
    try {
      setState(() {
        isLoading = true;
      });

      await controller.fetchSavedTrip();
      data = controller.tripList;

      if (mounted) {
        setState(() {
          itineraries = data.toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading itineraries: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.tripList.clear();
  }

  Future<void> navigateToItinerary(int index) async {
    try {
      final description =
          AppService.getNormalText(itineraries[index].aiResponse);
      final budget = itineraries[index].tripRequest.tripBudget;

      final translatedDesc = await translator
          .translate(description, from: 'auto', to: context.locale.languageCode)
          .then((result) => result.text)
          .catchError((error) {
        print('Translation error: $error');
        return description;
      });

      final translatedBudg = await translator
          .translate(budget, from: 'es', to: context.locale.languageCode)
          .then((result) => result.text)
          .catchError((error) {
        print('Translation error: $error');
        return budget;
      });

      final needsRefresh = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ItineraryScreen(
            itineraryData: itineraries[index].toMap(),
            translatedDescription: translatedDesc,
            translatedBudget: translatedBudg,
            isCreateItinerary: false,
          ),
        ),
      );

      // Solo recarga si needsRefresh es true
      if (needsRefresh == true) {
        _loadSavedTrip();
      }
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    TextStyle _textStyleTiny = Theme.of(context).textTheme.bodySmall!;

    return Scaffold(
      floatingActionButton: ContactButtons(
        withoutAssistant: false,
        uniqueId: 'itinerariesPage',
      ),
      appBar: AppBar(
        title: Text('itinerary history', style: _textStyleMedium).tr(),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: const CircularProgressIndicator())
          : ListView.builder(
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                String description =
                    AppService.getNormalText(itineraries[index].aiResponse);
                String budget = itineraries[index].tripRequest.tripBudget;

                return InkWell(
                    onTap: () => navigateToItinerary(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100.0,
                                width: 100.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.0),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/destination/destination_${Random().nextInt(12)}.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star,
                                                  color: Colors.orange,
                                                  size: 16),
                                              SizedBox(width: 4),
                                              FutureBuilder<String>(
                                                future: translator
                                                    .translate(budget,
                                                        from: 'es',
                                                        to: context.locale
                                                            .languageCode)
                                                    .then(
                                                        (result) => result.text)
                                                    .catchError((error) {
                                                  print(
                                                      'Translation error: $error');
                                                  return budget;
                                                }),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return SizedBox(
                                                      height: 10,
                                                      width: 10,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.grey[
                                                                      400]!),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return Text(
                                                    snapshot.data ?? budget,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: _textStyleTiny.copyWith(
                                                        fontWeight:
                                                            fontSizeController
                                                                .obtainContrastFromBase(
                                                                    FontWeight
                                                                        .bold)),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    FutureBuilder<String>(
                                      future: translator
                                          .translate(description,
                                              from: 'auto',
                                              to: context.locale.languageCode)
                                          .then((result) => result.text)
                                          .catchError((error) {
                                        print('Translation error: $error');
                                        return description;
                                      }),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return SizedBox(
                                            height: 40,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.grey[400]!),
                                              ),
                                            ),
                                          );
                                        }
                                        return Text(
                                          snapshot.data ?? description,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: _textStyleMedium.copyWith(
                                              fontWeight: fontSizeController
                                                  .obtainContrastFromBase(
                                                      FontWeight.w400),
                                              color: Colors.grey[700]),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.green, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          itineraries[index].tripRequest.place,
                                          style: _textStyleTiny.copyWith(
                                            color: Colors.green,
                                            fontWeight: fontSizeController
                                                .obtainContrastFromBase(
                                                    FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
              },
            ),
    );
  }
}

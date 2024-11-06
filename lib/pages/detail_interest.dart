import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:travel_hour/blocs/bookmark_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/utils/sign_in_dialog.dart';
import 'package:travel_hour/widgets/bookmark_icon.dart';
import 'package:travel_hour/widgets/comment_count.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/widgets/love_count.dart';
import 'package:travel_hour/widgets/love_icon.dart';
import 'package:travel_hour/widgets/other_places.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/widgets/todo.dart';
import '../widgets/html_body.dart';
import 'package:get/get.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';

class DetailInterestPage extends StatefulWidget {
  final Place? place;

  const DetailInterestPage({Key? key, required this.place}) : super(key: key);

  @override
  _DetailInterestPageState createState() => _DetailInterestPageState();
}

class _DetailInterestPageState extends State<DetailInterestPage> {
  final String collectionName = 'places';
  Place? selectedPlace; // Variable para almacenar el lugar seleccionado

  @override
  void initState() {
    super.initState();
    selectedPlace = widget.place;
  }

  handleLoveClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;
    if (_guestUser) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onLoveIconClick(collectionName, selectedPlace!.timestamp);
    }
  }

  handleBookmarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;
    if (_guestUser) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onBookmarkIconClick(collectionName, selectedPlace!.timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = context.watch<SignInBloc>();
    final _heroTag = GlobalKey().toString();
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    // Verificamos si hay un lugar seleccionado
    if (selectedPlace == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'No hay datos',
            style: _textStyleMedium,
          ),
        ),
        body: Center(
          child: Text('No hay datos disponibles en este momento.',
              style: _textStyleMedium),
        ),
      );
    }

    // Aquí continúa tu código existente para mostrar los detalles del lugar
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Hero(
                  tag: 'featured_${selectedPlace!.timestamp}_$_heroTag',
                  child: _slidableImages(selectedPlace!),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 8, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Expanded(
                          child: Text(
                        selectedPlace!.location!,
                        style: _textStyleMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      IconButton(
                          icon: BuildLoveIcon(
                              collectionName: collectionName,
                              uid: sb.uid,
                              timestamp: selectedPlace!.timestamp),
                          onPressed: () {
                            handleLoveClick();
                          }),
                      IconButton(
                          icon: BuildBookmarkIcon(
                              collectionName: collectionName,
                              uid: sb.uid,
                              timestamp: selectedPlace!.timestamp),
                          onPressed: () {
                            handleBookmarkClick();
                          }),
                    ],
                  ),
                  Text(selectedPlace!.name!,
                      style: _textStyleLarge.copyWith(
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.w900),
                          letterSpacing: -0.6,
                          wordSpacing: 1,
                          color: Colors.grey[800])),
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  Row(
                    children: <Widget>[
                      LoveCount(
                          collectionName: collectionName,
                          timestamp: selectedPlace!.timestamp),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Feather.message_circle,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      CommentCount(
                          collectionName: collectionName,
                          timestamp: selectedPlace!.timestamp)
                    ],
                  ),
                ],
              ),
            ),
            HtmlBodyWidget(
              content: selectedPlace!.description.toString(),
              isIframeVideoEnabled: true,
              isVideoEnabled: true,
              isimageEnabled: true,
              fontSize: null,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TodoWidget(placeData: selectedPlace!),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 0, bottom: 40),
              child: OtherPlaces(
                stateName: selectedPlace!.state,
                timestamp: selectedPlace!.timestamp,
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _slidableImages(Place place) {
    return Container(
      color: Colors.white,
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: AnotherCarousel(
            dotBgColor: Colors.transparent,
            showIndicator: true,
            dotSize: 5,
            dotSpacing: 15,
            boxFit: BoxFit.cover,
            images: [
              CustomCacheImage(imageUrl: place.imageUrl1),
              CustomCacheImage(imageUrl: place.imageUrl2),
              CustomCacheImage(imageUrl: place.imageUrl3),
            ]),
      ),
    );
  }
}

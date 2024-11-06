import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Config {
  final String appName = 'Conecta Quindío';
  final String nameIa = 'Gloria';
  final double hoursDiff =
      1.0; // Se establece cada cuanto se va a consultar la ubicación
  final String mapAPIKey = 'AIzaSyBY5fqHDVdAiWD6dLVGDLiaW1iqo_WV2qA';
  final String countryName = 'Quindío';
  final String splashIcon = 'assets/images/splash.png';
  //final String supportEmail = 'quindioconecta@gmail.com';
  final String supportEmail = 'info@experienciaquindio.com';
  final String iOSAppId = '000000';
  final String url = 'https://conect-quin-ia.igni-soft.com';
  //final String media_url = 'https://media-conect-quind.igni-soft.com';
  final String media_url = 'https://media.experienciaquindio.com';
  //final String privacyPolicyUrl ='https://media-conect-quind.igni-soft.com/politica-privacidad.html';
  final String redirect_qr = 'https://ar-code.com';
  final String privacyPolicyUrl =
      'https://lanzamiento.experienciaquindio.com/politica_privacidad.html'; //Se cambio a la nueva

  //final String yourWebsiteUrl ='https://adminia.experienciaquindio.com/survey/1729370337-H80A1'; //Se cambio a la nueva
  final String yourWebsiteUrl = 'https://conect-quin-ia.igni-soft.com/survey/1730136842-QWQC3';
  final String facebookPageUrl = 'https://www.facebook.com/people/Experiencia-Quind%C3%ADo/61567895332609/';
  final String youtubeChannelUrl =
      'https://www.youtube.com/c/C%C3%A1maradeComercioArmenia';
  final String instagramUrl =
      'https://www.instagram.com/experienciaquindio/'; //Aqui va la url de instagram

  final String gmdvitaRegisterUrl =
      'https://conect-quin-ia.igni-soft.com/api/users';
  final String gmdvitaUpdateUrl =
      'https://conect-quin-ia.igni-soft.com/api/users/update';
  final String gmdvitaVerifyUrl =
      'https://conect-quin-ia.igni-soft.com/api/users/validate-firt-update';
  final String gmdvitaGetUserUrl =
      'https://conect-quin-ia.igni-soft.com/api/users/get-user';

  final String countriesUrl =
      'https://conect-quin-ia.igni-soft.com/api/location/countries';
  final String departmentsUrl =
      'https://conect-quin-ia.igni-soft.com/api/location/countries/:countryId/departments';
  final String citiesUrl =
      'https://conect-quin-ia.igni-soft.com/api/location/departments/:departmentId/cities';

  final String routeMapUrl = 'https://www.google.com/maps/d/u/1/embed?mid=';

  // app theme color - primary color
  static final Color appThemeColor = const Color(0xFFA8CF45);

  //special two states name that has been already upload from the admin panel
  final String specialState1 = 'Salento';
  final String specialState2 = 'Filandia';

  //relplace by your country lattitude & longitude
  final CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(4.554686074372337, -75.6575986631806), //here
    zoom: 10,
  );

  //google maps marker icons
  final String airportPinIcon = 'assets/images/markers/airport_pin.png';
  final String attractionPinIcon = 'assets/images/markers/attractions_pin.png';
  final String atmPinIcon = 'assets/images/markers/atm_pin.png';
  final String destinationMarkerIcon =
      'assets/images/markers/destination_map_marker.png';
  final String drivingMarkerIcon = 'assets/images/markers/driving_pin.png';
  final String eventPinIcon = 'assets/images/markers/event_pin.png';
  final String gasStationPinIcon = 'assets/images/markers/gas_station_pin.png';
  final String hospitallPinIcon = 'assets/images/markers/hospital_pin.png';
  final String hotelPinIcon = 'assets/images/markers/hotel_pin.png';
  final String museumPinIcon = 'assets/images/markers/museum_pin.png';
  final String parkingPinIcon = 'assets/images/markers/parking_pin.png';
  final String restaurantPinIcon = 'assets/images/markers/restaurant_pin.png';
  final String touristPinIcon = 'assets/images/markers/tourist_pin.png';
  final String pointMarkerIcon =
      'assets/images/markers/destination_map_marker_2.png';
  final String pointMarkerIcon2 =
      'assets/images/markers/destination_map_marker_3.png';
  final String exchangeHousesPinIcon =
      'assets/images/markers/exchange_houses_pin.png';
  final String shoppingMallPinIcon =
      'assets/images/markers/shopping_mall_pin.png';

  //Intro images
  final String introImage1 = 'assets/images/travel1.png';
  final String introImage2 = 'assets/images/travel2.png';
  final String introImage3 = 'assets/images/travel6.png';

  final String AIGamesBackground = 'assets/images/ia_bg.png';

  //Language Setup
  final List<String> languages = ['English', 'Spanish', 'French'];

  static const String emptyImage =
      'https://innov8tiv.com/wp-content/uploads/2017/10/blank-screen-google-play-store-1280x720.png';

  final List<Map<String, String>> currencies = [
    {'code': 'USD', 'name': 'Dólar estadounidense', 'flag': '🇺🇸'},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'Libra esterlina', 'flag': '🇬🇧'},
    {'code': 'CAD', 'name': 'Dólar canadiense', 'flag': '🇨🇦'},
    {'code': 'AUD', 'name': 'Dólar australiano', 'flag': '🇦🇺'},
    {'code': 'JPY', 'name': 'Yen japonés', 'flag': '🇯🇵'},
    {'code': 'INR', 'name': 'Rupia india', 'flag': '🇮🇳'},
    {'code': 'NZD', 'name': 'Dólar neozelandés', 'flag': '🇳🇿'},
    {'code': 'CHF', 'name': 'Franco suizo', 'flag': '🇨🇭'},
    {'code': 'ZAR', 'name': 'Rand sudafricano', 'flag': '🇿🇦'},
    {'code': 'COP', 'name': 'Peso colombiano', 'flag': '🇨🇴'},
    {'code': 'BRL', 'name': 'Real brasileño', 'flag': '🇧🇷'},
    {'code': 'MXN', 'name': 'Peso mexicano', 'flag': '🇲🇽'},
    {'code': 'ARS', 'name': 'Peso argentino', 'flag': '🇦🇷'},
    {'code': 'CLP', 'name': 'Peso chileno', 'flag': '🇨🇱'},
    {'code': 'PEN', 'name': 'Sol peruano', 'flag': '🇵🇪'},
    {'code': 'BOB', 'name': 'Boliviano', 'flag': '🇧🇴'},
    {'code': 'UYU', 'name': 'Peso uruguayo', 'flag': '🇺🇾'},
    {'code': 'PYG', 'name': 'Guaraní paraguayo', 'flag': '🇵🇾'},
    {'code': 'VES', 'name': 'Bolívar venezolano', 'flag': '🇻🇪'},
    {'code': 'CNY', 'name': 'Yuan chino', 'flag': '🇨🇳'},
    {'code': 'HKD', 'name': 'Dólar de Hong Kong', 'flag': '🇭🇰'},
    {'code': 'SGD', 'name': 'Dólar de Singapur', 'flag': '🇸🇬'},
    {'code': 'KRW', 'name': 'Won surcoreano', 'flag': '🇰🇷'},
    {'code': 'IDR', 'name': 'Rupia indonesia', 'flag': '🇮🇩'},
    {'code': 'THB', 'name': 'Baht tailandés', 'flag': '🇹🇭'},
    {'code': 'VND', 'name': 'Dong vietnamita', 'flag': '🇻🇳'},
    {'code': 'MYR', 'name': 'Ringgit malasio', 'flag': '🇲🇾'},
    {'code': 'PHP', 'name': 'Peso filipino', 'flag': '🇵🇭'},
    {'code': 'RUB', 'name': 'Rublo ruso', 'flag': '🇷🇺'},
    {'code': 'TRY', 'name': 'Lira turca', 'flag': '🇹🇷'},
    {'code': 'SAR', 'name': 'Riyal saudí', 'flag': '🇸🇦'},
    {'code': 'AED', 'name': 'Dirham de EAU', 'flag': '🇦🇪'},
    {'code': 'ILS', 'name': 'Nuevo séquel israelí', 'flag': '🇮🇱'},
    {'code': 'EGP', 'name': 'Libra egipcia', 'flag': '🇪🇬'},
    {'code': 'NGN', 'name': 'Naira nigeriano', 'flag': '🇳🇬'},
    {'code': 'KES', 'name': 'Chelín keniano', 'flag': '🇰🇪'},
    {'code': 'SEK', 'name': 'Corona sueca', 'flag': '🇸🇪'},
    {'code': 'NOK', 'name': 'Corona noruega', 'flag': '🇳🇴'},
    {'code': 'DKK', 'name': 'Corona danesa', 'flag': '🇩🇰'},
    {'code': 'PLN', 'name': 'Złoty polaco', 'flag': '🇵🇱'},
    {'code': 'CZK', 'name': 'Corona checa', 'flag': '🇨🇿'},
    {'code': 'HUF', 'name': 'Forinto húngaro', 'flag': '🇭🇺'},
    {'code': 'RON', 'name': 'Leu rumano', 'flag': '🇷🇴'},
  ];

  final String token =
      '104|tERTv6JWIjAWFRuhf6iBc4rokKdmq35kStO7kpsib114af9d'; //Token del usuario autenticado a usar para el escaneo de puntos
  final String authUserId =
      '3'; //Id del usuario autenticado a usar para el escaneo de puntos

  final String privateKey =
      'BB5mpb7mPR5_dxroy9wEWCUXDuOKwl8lRwPaBkddbTbl6eAUz0K4uRbCH2T43A9cP4cZKqd0HAk5jF3x8qyv7Xo';
}

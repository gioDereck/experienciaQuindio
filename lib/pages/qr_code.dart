import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:travel_hour/config/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';
import 'dart:async';
// import 'package:responsive_builder/responsive_builder.dart';

void showCustomAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Definimos los breakpoints
          const smallScreenWidth = 600;
          const mediumScreenWidth = 1024;

          // Determinamos el ancho de pantalla actual
          final screenWidth = constraints.maxWidth;

          // Variables para ajustar el diseño según el breakpoint
          double containerWidth;
          double iconSize;
          double titleFontSize;
          double messageFontSize;
          double buttonPaddingHorizontal;
          double buttonPaddingVertical;
          double iconPadding;
          double lineWidthExtraPixels;

          if (screenWidth < smallScreenWidth) {
            // Pantallas pequeñas (móviles)
            containerWidth = screenWidth * 0.85;
            iconSize = 40;
            titleFontSize = 24;
            messageFontSize = 16;
            buttonPaddingHorizontal = 20;
            buttonPaddingVertical = 10;
            iconPadding = 10;
            lineWidthExtraPixels = 40.0;
          } else if (screenWidth < mediumScreenWidth) {
            // Pantallas medianas (tablets)
            containerWidth = screenWidth * 0.6;
            iconSize = 55; // Reducido un poco
            titleFontSize = 28; // Reducido un poco
            messageFontSize = 18; // Reducido un poco
            buttonPaddingHorizontal = 25; // Reducido un poco
            buttonPaddingVertical = 12; // Reducido un poco
            iconPadding = 12; // Reducido un poco
            lineWidthExtraPixels = 55.0;
          } else {
            // Pantallas grandes (escritorio)
            containerWidth = screenWidth * 0.4;
            iconSize = 60; // Reducido
            titleFontSize = 30; // Reducido
            messageFontSize = 20; // Reducido
            buttonPaddingHorizontal = 30; // Reducido
            buttonPaddingVertical = 15; // Reducido
            iconPadding = 15; // Reducido
            lineWidthExtraPixels = 60.0;
          }

          // Altura total del ícono
          double iconTotalHeight = iconSize + (iconPadding * 2);

          // Calculamos lineTopPosition para alinear la línea roja con el ícono
          double lineTopPosition = (iconTotalHeight / 2) - (40.0 / 2) + 18.0;

          return Center(
            child: Material(
              color: Colors.transparent, // Fondo transparente
              child: Container(
                width: containerWidth, // Ancho ajustado según el breakpoint
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Línea roja en el fondo
                    Positioned(
                      top:
                          lineTopPosition, // Ajustado para alinear con el ícono
                      right: 0.0, // Ajusta hacia la derecha
                      child: Container(
                        height: 40.0,
                        width: (containerWidth * 0.5) + lineWidthExtraPixels,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            bottomLeft: Radius.circular(50.0),
                          ),
                        ),
                      ),
                    ),
                    // Contenido del modal
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Ajuste al contenido
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Centrado horizontal
                        children: [
                          // Ícono circular con gradiente
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.redAccent,
                                    Colors.red,
                                  ],
                                  center: Alignment(-0.2, -0.2),
                                  radius: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: iconSize,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          // Título
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'were_sorry',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ).tr(),
                          ),
                          SizedBox(height: 8.0),
                          // Mensaje
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: messageFontSize,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ).tr(),
                          ),
                          SizedBox(height: 20.0),
                          // Botón cerrar
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFBEA1E6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: buttonPaddingHorizontal,
                                  vertical: buttonPaddingVertical,
                                ),
                                child: Text(
                                  'close',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: messageFontSize,
                                  ),
                                ).tr(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void showSuccessAlertDialog(BuildContext context, int points) {
  final String points_added_successfully = easy.tr('points_added_successfully');
  final String these_are_your_current_points =
      easy.tr('these_are_your_current_points');

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Definimos los breakpoints
          const smallScreenWidth = 600;
          const mediumScreenWidth = 1024;

          // Determinamos el ancho de pantalla actual
          final screenWidth = constraints.maxWidth;

          // Variables para ajustar el diseño según el breakpoint
          double containerWidth;
          double titleFontSize;
          double messageFontSize;
          double pointsFontSize;
          double buttonPaddingHorizontal;
          double buttonPaddingVertical;
          double iconSize;
          double contentMarginTop;
          double lineWidthExtraPixels;

          if (screenWidth < smallScreenWidth) {
            // Pantallas pequeñas (móviles)
            containerWidth = screenWidth * 0.85;
            titleFontSize = 32;
            messageFontSize = 16;
            pointsFontSize = 22;
            buttonPaddingHorizontal = 30;
            buttonPaddingVertical = 12;
            iconSize = 24;
            contentMarginTop = 70.0; // Margen superior para móviles
            lineWidthExtraPixels = 50;
          } else if (screenWidth < mediumScreenWidth) {
            // Pantallas medianas (tablets)
            containerWidth = screenWidth * 0.6;
            titleFontSize = 40;
            messageFontSize = 20;
            pointsFontSize = 28;
            buttonPaddingHorizontal = 40;
            buttonPaddingVertical = 15;
            iconSize = 30;
            contentMarginTop = 70.0; // Margen superior para móviles
            lineWidthExtraPixels = 50;
          } else {
            // Pantallas grandes (escritorio)
            containerWidth = screenWidth * 0.4;
            titleFontSize = 48;
            messageFontSize = 24;
            pointsFontSize = 34;
            buttonPaddingHorizontal = 50;
            buttonPaddingVertical = 20;
            iconSize = 36;
            contentMarginTop = 70.0; // Margen superior para móviles
            lineWidthExtraPixels = 50;
          }

          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: containerWidth, // Ancho ajustado según el breakpoint
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Barra lila con información de puntos
                    Positioned(
                      top: 20.0, // Ajustado para que sobresalga hacia arriba
                      right: 0.0,
                      child: Container(
                        width: (containerWidth * 0.5) + lineWidthExtraPixels,
                        decoration: BoxDecoration(
                          color: Color(0xFFA085BC), // Color lila
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            bottomLeft: Radius.circular(50.0),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Texto "PUNTOS" y "ACTUALES" en dos líneas
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'points_capital',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        12, // Ajustar tamaño si es necesario
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).tr(),
                                Text(
                                  'currents',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        12, // Ajustar tamaño si es necesario
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).tr(),
                              ],
                            ),
                            SizedBox(width: 8.0),
                            // Número de puntos
                            Text(
                              points.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: pointsFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            // Ícono de trofeo
                            Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: iconSize,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contenido del modal con margen superior
                    Container(
                      margin: EdgeInsets.only(top: contentMarginTop),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Ajuste al contenido
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Centrado horizontal
                        children: [
                          // Título de éxito
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'success',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ).tr(),
                          ),
                          SizedBox(height: 8.0),
                          // Mensaje de éxito
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '$points_added_successfully,\n'
                              '$these_are_your_current_points.',
                              style: TextStyle(
                                fontSize: messageFontSize,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          // Botón cerrar
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color(0xFFA7CF3D), // Color verde
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: buttonPaddingHorizontal,
                                  vertical: buttonPaddingVertical,
                                ),
                                child: Text(
                                  'close',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: messageFontSize,
                                  ),
                                ).tr(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  bool _isScanning = false; // Controla si el escaneo está en progreso
  final List<String> _audioExtensions = [
    '.mp3',
    '.wav',
    '.aac',
    '.m4a',
    '.flac'
  ];

  Timer? _scanTimer; // Añade esta línea para el temporizador

  void _startScanning() {
    // showCustomAlertDialog(context, 'Prueba');
    // showSuccessAlertDialog(context, 600);
    setState(() {
      _isScanning = true; // Inicia el escaneo y muestra el loading
    });

    // Iniciar el temporizador de 15 segundos
    _scanTimer = Timer(Duration(seconds: 15), () {
      if (mounted && _isScanning) {
        setState(() {
          _isScanning = false; // Detener el escaneo
        });
        _showErrorDialog(easy.tr('no_qr_found')); // Mostrar mensaje de error
      }
    });
  }

  Future<void> _handleQrCode(String code) async {
    // Cancelar el temporizador si está activo
    if (_scanTimer != null && _scanTimer!.isActive) {
      _scanTimer!.cancel();
    }

    // Verifica si el código es una URL
    if (Uri.tryParse(code)?.hasAbsolutePath ?? false) {
      // Si es una URL válida, verifica si es de audio
      if (await _isAudioUrl(code)) {
        _showResultDialogWithDetails(null, null, code);
      } else {
        // Si no es de audio, intenta abrir la URL
        if (await canLaunchUrl(Uri.parse(code))) {
          await launchUrl(Uri.parse(code),
              mode: LaunchMode.externalApplication);
        } else {
          _showErrorDialog('cannot_open_the_url' + ': ' + code);
        }
      }
    } else {
      // Intenta decodificar como JSON
      try {
        final Map<String, dynamic> decodedJson = json.decode(code);

        // Verificar si el JSON contiene la propiedad 'hash'
        if (decodedJson.containsKey('hash')) {
          // Obtener instancia de SignInBloc
          final SignInBloc sb = context.read<SignInBloc>();
          if (sb.uid == null || sb.uid!.isEmpty) {
            // El usuario no ha iniciado sesión, mostrar alerta
            _showLoginRequiredDialog();
          } else {
            // El usuario ha iniciado sesión, realizar la petición POST
            await _sendPostRequest(decodedJson, sb.uid!, sb.email!);
          }
        } else if (decodedJson.containsKey('title') &&
            decodedJson.containsKey('description')) {
          // Si el objeto contiene título y descripción, muestra un diálogo con los detalles
          String? title = decodedJson['title'];
          String? description = decodedJson['description'];
          String? url = decodedJson['url'];
          _showResultDialogWithDetails(title, description, url);
        } else {
          // Si es un objeto sin los campos esperados, muestra alerta de código QR inválido
          _showErrorDialog(easy.tr('no_qr_found'));
        }
      } catch (e) {
        // Si no es JSON, muestra alerta de código QR inválido
        _showErrorDialog(easy.tr('no_qr_found'));
      } finally {
        // Asegurarse de detener el escaneo
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }
    }
  }

  // Método para enviar la petición POST
  // Future<void> _sendPostRequest(
  //     Map<String, dynamic> data, String uid, String email) async {
  //   String url = '${Config().url}/api/save-points';

  //   print(data);
  //   // Espera el resultado del fetchUserData
  //   // int userId = await fetchUserData(email);

  //   // Preparar el cuerpo de la petición
  //   Map<String, dynamic> body = {
  //     'qrId': data['qrId']?.toString() ?? '',
  //     'hash': data['hash'] ?? '',
  //     'uid': uid,
  //     // 'userId': userId // Ajusta según sea necesario
  //   };

  //   print(body);

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       body: json.encode(body),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ' + Config().token,
  //       },
  //     );
  //     // Decodificar la respuesta del servidor
  //     final Map<String, dynamic> responseBody = json.decode(response.body);
  //     // Verificar el estado de la respuesta
  //     if (responseBody['status'] == 'success') {
  //       // Extraer el mensaje y la cantidad de puntos
  //       final int points = responseBody['message']['points'] ?? 0;
  //       showSuccessAlertDialog(context, points);
  //     } else {
  //       // Mostrar mensaje de error si el estado no es 'success'
  //       String errorMessage =
  //           responseBody['errors'] ?? easy.tr('error_in_the_operation');
  //       showCustomAlertDialog(context, errorMessage);
  //     }
  //   } catch (e) {
  //     print('Error durante la petición POST: $e');
  //     showCustomAlertDialog(context, easy.tr('error_sending_the_request'));
  //   }
  // }

  Future<void> _sendPostRequest(
    Map<String, dynamic> data, String uid, String email) async {
  String url = '${Config().url}/api/save-points';

  print(data);
  // Preparar el cuerpo de la petición
  Map<String, dynamic> body = {
    'qrId': data['qrId']?.toString() ?? '',
    'hash': data['hash'] ?? '',
    'email': email,
    // 'userId': userId // Ajusta según sea necesario
  };

  print(body);

  try {
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + Config().token,
      },
    );

    // Decodificar la respuesta del servidor
    final Map<String, dynamic> responseBody = json.decode(response.body);
    print(responseBody); // Añade esto para depuración

    // Verificar el estado de la respuesta
    if (responseBody['status'] == 'success') {
      // Extraer el mensaje y la cantidad de puntos
      final int points = responseBody['message']['points'] ?? 0;
      showSuccessAlertDialog(context, points);
    } else {
      // Manejar 'errors' como una lista o cadena
      String errorMessage = easy.tr('error_in_the_operation'); // Valor por defecto
      if (responseBody['errors'] != null) {
        if (responseBody['errors'] is List) {
          // Concatenar todos los mensajes de error
          errorMessage = (responseBody['errors'] as List)
              .map((e) => e.toString())
              .join('\n');
        } else if (responseBody['errors'] is String) {
          errorMessage = responseBody['errors'];
        }
      }
      showCustomAlertDialog(context, errorMessage);
    }
  } catch (e) {
    print('Error durante la petición POST: $e');
    showCustomAlertDialog(context, easy.tr('error_sending_the_request'));
  }
}


  Future<int> fetchUserData(String email) async {
    final url = Config().gmdvitaGetUserUrl + '?email=$email';
    final headers = {
      'Authorization': 'Bearer ' + Config().token,
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final userData = data['data'];
          print(userData);
          return userData['id'] ?? 1; // Retorna 1 si no se encuentra el id
        } else {
          print('Error: ${data['status']}');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
    return 1;
  }

  // Método para mostrar diálogo de éxito
  void _showSuccessDialog(String message) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('success', style: _textStyleMedium).tr(),
          ],
        ),
        content: Text(message, style: _textStyleMedium),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  _isScanning = false;
                });
              }
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFFA085BC),
            ),
            child: Text('close', style: _textStyleMedium).tr(),
          ),
        ],
      ),
    );
  }

  // Método para mostrar diálogo de error
  void _showErrorDialog(String message) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error', style: _textStyleMedium).tr(),
          ],
        ),
        content: Text(message, style: _textStyleMedium),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  _isScanning = false;
                });
              }
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFFA085BC),
            ),
            child: Text('close', style: _textStyleMedium).tr(),
          ),
        ],
      ),
    );
  }

  // Método para mostrar diálogo de inicio de sesión requerido
  void _showLoginRequiredDialog() {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Iniciar sesión', style: _textStyleMedium).tr(),
          ],
        ),
        content: Text(
          'you_must_log_in_to_scan_this_qr_code',
          style: _textStyleMedium,
        ).tr(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFFA085BC),
            ),
            child: Text('close', style: _textStyleMedium).tr(),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar a la pantalla de inicio de sesión
              Navigator.pushNamed(context, '/signIn');
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFFA085BC),
            ),
            child: Text('Iniciar sesión', style: _textStyleMedium).tr(),
          ),
        ],
      ),
    );
  }

  // Método para verificar si la URL es de audio
  Future<bool> _isAudioUrl(String url) async {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    // Verificar si la URL termina con una extensión de audio conocida
    bool hasAudioExtension = _audioExtensions.any((ext) => path.endsWith(ext));
    if (hasAudioExtension) {
      return true;
    }

    // Si no termina con una extensión de audio, verificar el tipo MIME con una solicitud HEAD
    try {
      final response = await http.head(uri);
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.startsWith('audio/')) {
          return true;
        }
      }
    } catch (e) {
      print('Error al verificar el tipo MIME: $e');
    }

    return false;
  }

  void _showResultDialogWithDetails(
      String? title, String? description, String? url) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
      context: context,
      builder: (context) {
        bool isAudio = false;
        if (url != null && Uri.tryParse(url)?.hasAbsolutePath == true) {
          isAudio =
              _audioExtensions.any((ext) => url.toLowerCase().endsWith(ext));
        }

        return AlertDialog(
          contentPadding: EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15), // Ajusta el radio del borde si lo deseas
          ),
          content: Container(
            width: MediaQuery.of(context).size.width *
                0.95, // Ancho ajustado del modal
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/images/location.png', // Reemplaza con la ruta correcta de tu imagen
                      width: 130, // Ajusta el tamaño de la imagen
                      height: 130,
                    ),
                    Center(
                      child: Text(
                        title ?? 'place description',
                        style: _textStyleLarge.copyWith(
                          fontWeight: fontSizeController
                              .obtainContrastFromBase(FontWeight.w800),
                          color: Theme.of(context)
                              .primaryColor, // Usa el color primario del tema
                        ),
                        textAlign: TextAlign.center,
                      ).tr(),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                if (!isAudio)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      description ?? (url ?? 'Scanned Data'),
                      textAlign: TextAlign.justify,
                      style: _textStyleMedium,
                    ),
                  ),
                SizedBox(height: 25),
                if (isAudio && url != null) AudioPlayerWidget(audioUrl: url),
                if (!isAudio && url != null)
                  ElevatedButton(
                    onPressed: () async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        _showErrorDialog('No se puede abrir la URL: $url');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA7CF3D),
                    ),
                    child: Text('open url', style: _textStyleMedium).tr(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _isScanning = false;
                  });
                }
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFA085BC),
              ),
              child: Text('close', style: _textStyleMedium).tr(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel(); // Añade esta línea para cancelar el temporizador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cámara activa (MobileScanner)
          MobileScanner(
            fit: BoxFit.cover, // Hace que el escáner cubra todo el espacio
            onDetect: (capture) {
              if (!_isScanning) return; // Solo escanea cuando está en progreso
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  setState(() {
                    _isScanning =
                        false; // Detiene el escaneo cuando se detecta un código
                  });
                  _handleQrCode(code); // Maneja el código QR escaneado
                }
              }
            },
          ),
          // Indicador de carga cuando se está escaneando
          if (_isScanning)
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          // Botón para regresar en la parte superior izquierda
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).pop(); // Regresa a la pantalla anterior
              },
            ),
          ),
          // Botón redondo centrado en la parte inferior para iniciar el escaneo
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _startScanning,
                backgroundColor: Theme.of(context).primaryColor,
                child:
                    Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
                elevation: 8.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Liberar recursos del reproductor
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Text('No se pudo reproducir el audio.', style: _textStyleMedium)
          .tr();
    }

    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return Center(
          // Centra el Row dentro del padre
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Ajusta el Row al tamaño de sus hijos
            children: [
              Container(
                width: 85, // Define un tamaño fijo para el contenedor
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .primaryColor, // Fondo del botón (opcional)
                ),
                child: IconButton(
                  padding: EdgeInsets.zero, // Elimina el padding por defecto
                  iconSize: 70, // Tamaño del ícono ajustado
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.play();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

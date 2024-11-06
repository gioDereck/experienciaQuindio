import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  try {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  } catch (e) {
    print('Error loading asset: $path - $e');
    throw Exception(
        'Failed to load asset: $path'); // Lanza una excepción si hay un error
  }
}

Future<Uint8List?> loadAndResizeImage(
    String assetPath, int width, int height) async {
  try {
    // Cargar la imagen desde el recurso local
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Decodificar la imagen desde los bytes
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      // Redimensionar la imagen
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height);

      // Convertir la imagen redimensionada a bytes
      return Uint8List.fromList(img.encodePng(
          resizedImage)); // O encodeJpg(resizedImage) si prefieres JPG
    } else {
      throw Exception('Error al decodificar la imagen.');
    }
  } catch (e) {
    print('Error loading and resizing image: $e');
    return null; // Retorna null si hay un error
  }
}

Future<Uint8List?> loadAndResizeImage2(String assetPath,
    {int? targetWidth, int? targetHeight}) async {
  try {
    // Cargar la imagen desde el recurso local
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Decodificar la imagen desde los bytes
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      int width = image.width;
      int height = image.height;

      // Calcular nuevas dimensiones manteniendo la proporción
      if (targetWidth != null && targetHeight == null) {
        // Ajustar ancho, calcular altura proporcional
        double aspectRatio = image.height / image.width;
        width = targetWidth;
        height = (targetWidth * aspectRatio).round();
      } else if (targetHeight != null && targetWidth == null) {
        // Ajustar altura, calcular ancho proporcional
        double aspectRatio = image.width / image.height;
        height = targetHeight;
        width = (targetHeight * aspectRatio).round();
      } else if (targetWidth != null && targetHeight != null) {
        // Si se especifican ambos, calcular escala para mantener la proporción
        double aspectRatioOriginal = image.width / image.height;
        double aspectRatioTarget = targetWidth / targetHeight;

        if (aspectRatioTarget > aspectRatioOriginal) {
          // Ajustar altura, calcular ancho proporcional
          double aspectRatio = image.width / image.height;
          height = targetHeight;
          width = (targetHeight * aspectRatio).round();
        } else {
          // Ajustar ancho, calcular altura proporcional
          double aspectRatio = image.height / image.width;
          width = targetWidth;
          height = (targetWidth * aspectRatio).round();
        }
      }
      // Si no se especifica ninguna dimensión, mantener tamaño original

      // Redimensionar la imagen manteniendo la proporción
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height);

      // Convertir la imagen redimensionada a bytes
      return Uint8List.fromList(img.encodePng(resizedImage));
    } else {
      throw Exception('Error al decodificar la imagen.');
    }
  } catch (e) {
    print('Error loading and resizing image: $e');
    return null;
  }
}

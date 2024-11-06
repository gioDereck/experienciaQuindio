import 'package:flutter/material.dart';
import 'package:travel_hour/config/config.dart';
import 'package:easy_localization/easy_localization.dart';

class TransparentImageModal extends StatelessWidget {
  final VoidCallback onClose;
  final int resizeImagePointByHeight = 350;

  const TransparentImageModal({
    Key? key,
    required this.onClose,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double proportionalWidth = MediaQuery.of(context).size.width < 580 ? 0.8 : MediaQuery.of(context).size.width < 950 ? 0.5 : 0.3; 
    
    double widthImage = MediaQuery.of(context).size.height < resizeImagePointByHeight ? MediaQuery.of(context).size.width 
      : MediaQuery.of(context).size.width * proportionalWidth;
    double heightImage = MediaQuery.of(context).size.height < resizeImagePointByHeight ? MediaQuery.of(context).size.height * 0.8 
      : MediaQuery.of(context).size.height * 0.6;

    return Stack(
      children: [
        // Fondo transparente
        /*
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        */
        // Contenido del modal
        Positioned(
          bottom: MediaQuery.of(context).size.height < resizeImagePointByHeight ? 40 : 80,
          right: 0,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  (context.locale.languageCode == 'en'
                  ? '${Config().media_url}/uploads/2024/09/app/ia_options/gloria_mensaje_comp_english.png'
                  : context.locale.languageCode == 'fr'
                      ? '${Config().media_url}/uploads/2024/09/app/ia_options/gloria_mensaje_comp_frances.png'
                      : '${Config().media_url}/uploads/2024/09/app/ia_options/lucia_mensaje_completa.png'),
                  fit: BoxFit.contain,
                  width: widthImage,
                  height: heightImage,
                ),
              ),
              
              // Botón de cerrar
              Positioned(
                top: 10,
                right: 30,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
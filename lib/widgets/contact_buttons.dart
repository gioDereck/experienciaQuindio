import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:travel_hour/pages/emergency_numbers.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactButtons extends StatelessWidget {
  final bool withoutAssistant;
  final String uniqueId; // Añadido para asegurar unicidad de los heroTags

  const ContactButtons(
      {Key? key, required this.withoutAssistant, required this.uniqueId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nuevo botón circular con el ícono de IA en la primera posición, fondo blanco y sombra mínima
        /*
        (withoutAssistant ? SizedBox.shrink() : FloatingActionButton(
          heroTag: "aiButton", // Etiqueta única para el botón IA
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => IaOptionsPage()));
          },
          child: Image.asset(
            'assets/images/icon_ia.gif', // Ruta del ícono GIF
            width: 36,
            height: 36,
          ),
          backgroundColor: Colors.white, // Fondo blanco
          elevation: 4, // Sombra mínima
        )),
        */

        // Botón con color A7CF3D para enviar mensaje de WhatsApp
        FloatingActionButton(
          heroTag: "whatsappButton_$uniqueId", // Etiqueta única
          onPressed: () {
            _launchURL("https://wa.me/+573233561884");
          }, // Envío de mensaje de WhatsApp
          child: Icon(FontAwesome.whatsapp),
          backgroundColor: Color(0xFFFFD843), // Color hexadecimal personalizado
        ),
        // Espacio entre los botones
        SizedBox(height: 16),
        // Botón de llamada
        FloatingActionButton(
          heroTag: "callButton_$uniqueId", // Etiqueta única
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EmergencyNumbersPage())); // Navega a EmergencyNumbersPage
          },
          child: Icon(Icons.phone),
          backgroundColor: Color(0xFFF2565C), // Color hexadecimal personalizado
        ),
      ],
    );
  }

  // Método para lanzar la URL
  // ignore: unused_element
  void _launchURL(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

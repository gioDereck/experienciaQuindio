import 'package:flutter/material.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/widgets/contact_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:url_launcher/url_launcher.dart';

class ImmersionQRPage extends StatefulWidget {
  ImmersionQRPage({Key? key}) : super(key: key);
  _ImmersionQRPageState createState() => _ImmersionQRPageState();
}

class _ImmersionQRPageState extends State<ImmersionQRPage>
    with AutomaticKeepAliveClientMixin {
  final List<Map<String, String>> inmersePlaces = [
    {
      'name': 'PARQUE DE SALENTO',
      'url': 'https://ar-code.com/YJ3XecLme',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/parque/inmersion_parque_salento.png',
      'image': 'https://i.imgur.com/S5OJVPy.jpeg'
    },
    {
      'name': 'VALLE DEL COCORA',
      'url': 'https://ar-code.com/WckPg0cEW',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/valle_de_cocora/inmersion_valle_cocora.png',
      'image': 'https://i.imgur.com/40pc7PB.jpeg'
    },
    {
      'name': 'PARQUE DEL CAFÉ',
      'url': 'https://ar-code.com/ey74mjWWh',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/montenegro/parque_cafe/inmersion_parque_caf%C3%A9.png',
      'image': 'https://i.imgur.com/vEa4W3G.jpeg'
    },
    {
      'name': 'PARQUE DE SALENTO',
      'url': 'https://ar-code.com/YJ3XecLme',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/parque/inmersion_parque_salento.png',
      'image': 'https://i.imgur.com/S5OJVPy.jpeg'
    },
    {
      'name': 'VALLE DEL COCORA',
      'url': 'https://ar-code.com/WckPg0cEW',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/valle_de_cocora/inmersion_valle_cocora.png',
      'image': 'https://i.imgur.com/40pc7PB.jpeg'
    },
    {
      'name': 'PARQUE DEL CAFÉ',
      'url': 'https://ar-code.com/ey74mjWWh',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/montenegro/parque_cafe/inmersion_parque_caf%C3%A9.png',
      'image': 'https://i.imgur.com/vEa4W3G.jpeg'
    },
    {
      'name': 'PARQUE DE SALENTO',
      'url': 'https://ar-code.com/YJ3XecLme',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/parque/inmersion_parque_salento.png',
      'image': 'https://i.imgur.com/S5OJVPy.jpeg'
    },
    {
      'name': 'VALLE DEL COCORA',
      'url': 'https://ar-code.com/WckPg0cEW',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/valle_de_cocora/inmersion_valle_cocora.png',
      'image': 'https://i.imgur.com/40pc7PB.jpeg'
    },
    {
      'name': 'PARQUE DEL CAFÉ',
      'url': 'https://ar-code.com/ey74mjWWh',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/montenegro/parque_cafe/inmersion_parque_caf%C3%A9.png',
      'image': 'https://i.imgur.com/vEa4W3G.jpeg'
    },
    {
      'name': 'PARQUE DE SALENTO',
      'url': 'https://ar-code.com/YJ3XecLme',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/parque/inmersion_parque_salento.png',
      'image': 'https://i.imgur.com/S5OJVPy.jpeg'
    },
    {
      'name': 'VALLE DEL COCORA',
      'url': 'https://ar-code.com/WckPg0cEW',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/salento/valle_de_cocora/inmersion_valle_cocora.png',
      'image': 'https://i.imgur.com/40pc7PB.jpeg'
    },
    {
      'name': 'PARQUE DEL CAFÉ',
      'url': 'https://ar-code.com/ey74mjWWh',
      'qr_image':
          '${Config().media_url}/uploads/2024/09/places/montenegro/parque_cafe/inmersion_parque_caf%C3%A9.png',
      'image': 'https://i.imgur.com/vEa4W3G.jpeg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('ar_qr').tr(),
      ),
      floatingActionButton: ContactButtons(
        withoutAssistant: false,
        uniqueId: 'qrList',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculamos el número óptimo de columnas basado en el ancho disponible
          final double minCardWidth =
              160.0; // Ancho mínimo deseado para cada card
          int crossAxisCount = (constraints.maxWidth / minCardWidth).floor();
          crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      // Usamos un childAspectRatio dinámico basado en el contenido
                      childAspectRatio: 0.85,
                    ),
                    itemCount: inmersePlaces.length,
                    itemBuilder: (context, index) {
                      final item = inmersePlaces[index];
                      return LayoutBuilder(
                        builder: (context, cardConstraints) {
                          return ImmersionCard(
                            name: item['name']!,
                            imageUrl: item['image']!,
                            qrImageUrl: item[
                                'qr_image']!, // Añadimos la URL de la imagen QR
                            onTap: () async {
                              if (await canLaunchUrl(
                                  Uri.parse(item['url'] ?? ''))) {
                                await launchUrl(Uri.parse(item['url'] ?? ''),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                _showErrorDialog(
                                    'No se puede abrir la URL: ${item["url"]}');
                              }
                            },
                            maxWidth: cardConstraints.maxWidth,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
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

  @override
  bool get wantKeepAlive => true;
}

class ImmersionCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final double maxWidth;
  final String imageUrl;
  final String qrImageUrl; // Añadimos el parámetro para la imagen QR

  const ImmersionCard({
    Key? key,
    required this.name,
    required this.onTap,
    required this.maxWidth,
    required this.imageUrl,
    required this.qrImageUrl, // Requerimos la URL de la imagen QR
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double iconSize = maxWidth * 0.30;
    final double qrSize =
        maxWidth * 0.40; // Aumentamos un poco el tamaño respecto al icono
    final double titleFontSize = maxWidth * 0.06;
    final double numberFontSize = maxWidth * 0.07;
    final double buttonHeight = maxWidth * 0.15;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(maxWidth * 0.06),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(maxWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      qrImageUrl,
                      width: qrSize,
                      height: qrSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: Icon(Icons.videocam,
                        size: iconSize * 0.2, color: Colors.white),
                    label: Text(
                      'access',
                      style: TextStyle(fontSize: numberFontSize),
                    ).tr(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA7CF3D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonHeight / 2),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: maxWidth * 0.06,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

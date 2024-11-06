import 'package:flutter/material.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/services/platform_detection_service.dart';
import 'package:travel_hour/widgets/webView.dart';
import 'package:get/get.dart' as getx;
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

final mapData = [
  {'name': 'Ruta de Cafés Especiales', 'url': '1c1bHL7OtZ6ApF6vJ9fYag5Zwyqg'},
  {
    'name': 'Circuito Cruces, Filandia, Quimbaya, Montenegro y Armenia',
    'url': '1InGZA4aFMU2OugnqYJmc1kgfsLk'
  },
  {
    'name': 'Circuito Cruces, Salento y Circasia',
    'url': '1OLB8egFfvaq6Bt97GYpmuJxH4GE'
  },
  {
    'name': 'Microcircuito Boquia – Puente de la Explanación',
    'url': '1HOgmYZn0yzssdHiRnIAHQzWsZFA'
  },
  {
    'name': 'Corredor Cruces, Salento y Calarcá',
    'url': '1tIvbbP0Lswa2AckofTVIeb3kMvY'
  },
  {
    'name': 'Corredor Armenia, Calarcá, Buenavista y Pijao',
    'url': '1dXRqu39AXokz-CUKPD6vkl7nUdM'
  },
  {
    'name': 'Circuito Armenia, Calarcá, Córdoba, Pijao y Buenavista',
    'url': '12AaPhXuXiw0EhqxNU0jgsWK7wdY'
  },
  {
    'name': 'Ruta de Pueblos con Encanto',
    'url': '1On8isq9qC7ZSSOyBInsNBB2DiKo'
  },
  {
    'name': 'Ruta de Naturaleza y Aventura',
    'url': '1uM0CsWhtJVAGkeiipqbCiy_OcG8'
  },
  {'name': 'Ruta de Fondas Cafeteras', 'url': '1MPVr3Ivn0ID1dVhaXjEoBaIqtdg'},
  {
    'name': 'Ruta de Miradores delQuindío',
    'url': '1hsyRBv1_MBkkU_JaQK4td_JVnKY'
  },
  {'name': 'Ruta de Maestros Artesanos', 'url': '1dkppweYjcpPkX-aQDqWnK3kj_NY'}
];

class CoffeeRoutesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    final platformService = PlatformDetectionService();
    // Información detallada del dispositivo
    final deviceInfo = platformService.getDeviceInfo();

    // Obtenemos la altura y ancho total de la pantalla
    final screenHeight = deviceInfo['screenHeight'];
    final screenWidth = deviceInfo['screenWidth'];

    final isMobile = platformService.isMobileWeb;

    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Calculamos la altura de la imagen basada en el tamaño de la pantalla
    final imageHeight =
        isMobile && isPortrait ? screenHeight * 0.3 : screenHeight * 0.45;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            snap: false,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
            expandedHeight: 100,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.7),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final settings = context.dependOnInheritedWidgetOfExactType<
                    FlexibleSpaceBarSettings>();
                final deltaExtent = settings!.maxExtent - settings.minExtent;
                final t = (1.0 -
                        (settings.currentExtent - settings.minExtent) /
                            deltaExtent)
                    .clamp(0.0, 1.0);

                // Calcula el padding izquierdo basado en el factor de colapso
                final leftPadding =
                    Tween<double>(begin: 15.0, end: 60.0).transform(t);

                return FlexibleSpaceBar(
                  centerTitle: false,
                  title: Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: Text(
                      easy.tr('coffee routes').toUpperCase(),
                      style: _textStyleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: fontSizeController
                            .obtainContrastFromBase(FontWeight.w700),
                      ),
                    ),
                  ),
                  titlePadding: EdgeInsets.only(bottom: 15),
                  background: Container(
                    color: Theme.of(context).primaryColor,
                    height: 80,
                    width: double.infinity,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Imagen responsive
                Container(
                  width: screenWidth,
                  height: imageHeight,
                  child: Stack(
                    children: [
                      Image.network(
                        isMobile && isPortrait
                            ? '${Config().media_url}/uploads/2024/09/app/coffee_routes/fondo_movil.png'
                            : '${Config().media_url}/uploads/2024/09/app/coffee_routes/fondo_web.png',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        frameBuilder: (BuildContext context, Widget child,
                            int? frame, bool wasSynchronouslyLoaded) {
                          if (frame == null) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor));
                          }
                          return child;
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child:
                                Icon(Icons.error, size: 50, color: Colors.red),
                          );
                        },
                      ),
                      // Overlay oscuro
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: imageHeight * 0.5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 600 ? 48 : 24,
                          ),
                          child: Text(
                            easy.tr('coffee_routes desc'),
                            textAlign: TextAlign.center,
                            style: _textStyleMedium.copyWith(
                              color: Colors.white,
                              fontSize: screenWidth > 600 ? 24 : 18,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de rutas
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: screenWidth > 600 ? 24 : 16,
                  ),
                  itemCount: mapData.length,
                  itemBuilder: (context, index) {
                    final item = mapData[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: CoffeeRouteCard(
                        name: item['name']!,
                        url: '${Config().routeMapUrl}${item['url']!}',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoffeeRouteCard extends StatelessWidget {
  final String name;
  final String url;

  CoffeeRouteCard({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebView(url: url, label: name),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

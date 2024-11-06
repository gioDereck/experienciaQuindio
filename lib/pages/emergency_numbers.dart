import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class EmergencyNumbersPage extends StatefulWidget {
  EmergencyNumbersPage({Key? key}) : super(key: key);
  _EmergencyNumbersPageState createState() => _EmergencyNumbersPageState();
}

class _EmergencyNumbersPageState extends State<EmergencyNumbersPage> with AutomaticKeepAliveClientMixin {
  final List<Map<String, String>> emergencyNumbers = [
    {'name': 'Policía Nacional', 'number': '7383980', 'icon': 'police'},
    {'name': 'CAI Pórtico', 'number': '7493900', 'icon': 'police'},
    {'name': 'Tránsito Departamental', 'number': '7498750', 'icon': 'transit'},
    {'name': 'Defensa Civil', 'number': '7495950', 'icon': 'civil_defense'},
    {'name': 'Cruz Roja', 'number': '132 – 7494010', 'icon': 'red_cross'},
    {'name': 'Hospitales San Juan de Dios', 'number': '7493500', 'icon': 'hospital'},
    {'name': 'Red Salud Hospital Del Sur', 'number': '7371010', 'icon': 'hospital'},
    {'name': 'Cuerpo de Bomberos', 'number': '119', 'icon': 'firefighters'},
    {'name': 'Bomberos Estación Sinaí', 'number': '7379640', 'icon': 'fire_station'},
    {'name': 'Gas Emergencias', 'number': '164', 'icon': 'gas_emergency'},
    {'name': 'Acueducto Alcantarillado E.P.A', 'number': '7463871', 'icon': 'water_service'},
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('emergency numbers').tr(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculamos el número óptimo de columnas basado en el ancho disponible
          final double minCardWidth = 160.0; // Ancho mínimo deseado para cada card
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
                    itemCount: emergencyNumbers.length,
                    itemBuilder: (context, index) {
                      final item = emergencyNumbers[index];
                      return LayoutBuilder(
                        builder: (context, cardConstraints) {
                          return EmergencyCard(
                            name: item['name']!,
                            number: item['number']!,
                            icon: _getIcon(item['icon']),
                            onTap: () => _showDialDialog(
                              context,
                              easy.tr(item['name']!),
                              item['number']!,
                            ),
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

  IconData _getIcon(String? icon) {
    switch (icon) {
      case 'police':
        return Icons.local_police;
      case 'transit':
        return Icons.traffic;
      case 'civil_defense':
        return Icons.shield;
      case 'red_cross':
        return Icons.local_hospital;
      case 'hospital':
        return Icons.local_hospital;
      case 'firefighters':
        return Icons.local_fire_department;
      case 'fire_station':
        return Icons.fire_truck;
      case 'gas_emergency':
        return Icons.local_gas_station;
      case 'water_service':
        return Icons.water_drop;
      default:
        return Icons.phone;
    }
  }

  void _showDialDialog(BuildContext context, String name, String number) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${easy.tr("call to")} $name', style: _textStyleMedium),
        content: Text(
          '¿${easy.tr("do you want to call")} $number?',
          style: _textStyleMedium,
        ),
        actions: [
          TextButton(
            child: Text('cancel', style: _textStyleMedium).tr(),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('call', style: _textStyleMedium).tr(),
            onPressed: () {
              _launchDialer(number);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _launchDialer(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      throw 'No se puede lanzar $number';
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class EmergencyCard extends StatelessWidget {
  final String name;
  final String number;
  final IconData icon;
  final VoidCallback onTap;
  final double maxWidth;

  const EmergencyCard({
    Key? key,
    required this.name,
    required this.number,
    required this.icon,
    required this.onTap,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculamos tamaños dinámicos basados en el ancho disponible
    final double iconSize = maxWidth * 0.15;
    final double titleFontSize = maxWidth * 0.08;
    final double numberFontSize = maxWidth * 0.07;
    final double buttonHeight = maxWidth * 0.15;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(maxWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.all(maxWidth * 0.04),
                decoration: BoxDecoration(
                  color: Color(0xFFA085BC).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: Color(0xFFA085BC),
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: maxWidth * 0.02),
                    Text(
                      number,
                      style: TextStyle(
                        fontSize: numberFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.phone, size: iconSize * 0.6, color: Colors.white),
                  label: Text(
                    'call',
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
    );
  }
}
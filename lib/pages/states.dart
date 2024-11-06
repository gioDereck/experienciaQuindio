import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/state_bloc.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/models/colors.dart';
import 'package:travel_hour/models/state.dart';
import 'package:travel_hour/pages/state_based_places.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/widgets/pulsating_qr_button.dart';
import 'package:url_launcher/url_launcher.dart';

class StatesPage extends StatefulWidget {
  StatesPage({Key? key}) : super(key: key);

  @override
  _StatesPageState createState() => _StatesPageState();
}

class _StatesPageState extends State<StatesPage>
    with AutomaticKeepAliveClientMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> qrImagesAndLinks = [
    {
      'name': 'SALENTO',
      'image':
          '${Config().media_url}/uploads/2024/09/places/salento/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/cEF1Gt9w2'
    },
    {
      'name': 'PIJAO',
      'image':
          '${Config().media_url}/uploads/2024/09/places/pijao/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/7NFuKJV2b'
    },
    {
      'name': 'ARMENIA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/armenia/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/LqrTYQ0T6'
    },
    {
      'name': 'BUENA VISTA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/buenavista/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/OVQdHyiX4'
    },
    {
      'name': 'CALARCA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/calarca/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/zHWlrEqDK'
    },
    {
      'name': 'CORDOBA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/cordoba/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/1X3vvYf2j'
    },
    {
      'name': 'MONTENEGRO',
      'image':
          '${Config().media_url}/uploads/2024/09/places/montenegro/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/jXrMSXz9p'
    },
    {
      'name': 'LA TEBAIDA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/la_tebaida/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/YuPdimKw4'
    },
    {
      'name': 'FILANDIA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/filandia/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/Ji0aC4SNe'
    },
    {
      'name': 'GÉNOVA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/genova/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/MEsjHA5Lf'
    },
    {
      'name': 'QUIMBAYA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/quimbaya/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/wou1fVplE'
    },
    {
      'name': 'CIRCASIA',
      'image':
          '${Config().media_url}/uploads/2024/09/places/circasia/Yo-Amo-ar-code.png',
      'redirect': '${Config().redirect_qr}/MPvNTLmhK'
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      context.read<StateBloc>().getData(mounted);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _getColumnCount(double width) {
    if (width >= 1000) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  double _getAspectRatio(int columnCount) {
    if (columnCount == 1) return 3.5;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sb = context.watch<StateBloc>();
    final data = sb.data;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text('states', style: _textStyleMedium).tr(),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Feather.rotate_cw, size: 22),
            onPressed: () {
              context.read<StateBloc>().onReload(mounted);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        child: sb.hasData == false
            ? ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  EmptyPage(
                    icon: Feather.clipboard,
                    message: 'No States found',
                    message1: '',
                  ),
                ],
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final columnCount = _getColumnCount(constraints.maxWidth);

                  return GridView.builder(
                    padding: EdgeInsets.all(15),
                    physics: AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnCount,
                      childAspectRatio: _getAspectRatio(columnCount),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: data.length, // Removido el +1
                    itemBuilder: (context, index) {
                      return _ItemList(
                        d: data[index],
                        isCompact: columnCount == 1,
                      );
                    },
                  );
                },
              ),
        onRefresh: () async {
          context.read<StateBloc>().onRefresh(mounted);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ItemList extends StatelessWidget {
  final StateModel d;
  final bool isCompact;

  const _ItemList({
    Key? key,
    required this.d,
    this.isCompact = false,
  }) : super(key: key);

  String _normalizeText(String text) {
    return text
        .trim()
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
  }

  Map<String, String>? _getQrInfo(BuildContext context) {
    final statesPage = context.findAncestorStateOfType<_StatesPageState>();
    if (statesPage == null) return null;

    String normalizedStateName = _normalizeText(d.name!);

    final qrInfo = statesPage.qrImagesAndLinks.firstWhere(
      (item) => _normalizeText(item['name']!) == normalizedStateName,
      orElse: () => {'image': '', 'redirect': ''},
    );

    if (qrInfo['image']!.isNotEmpty) {
      //print('Found QR for: ${d.name} -> ${qrInfo['name']}');
      return qrInfo;
    }

    print('No QR found for: ${d.name}');
    return null;
  }

  Future<void> _launchQrUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri);
    } catch (e) {
      debugPrint('Error al abrir URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    final qrInfo = _getQrInfo(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final qrSize = isCompact ? 68.0 : constraints.maxWidth * 0.2;

        return Stack(
          children: [
            // Card Principal con texto
            InkWell(
              onTap: () => nextScreen(
                context,
                StateBasedPlaces(
                  stateName: d.name,
                  color: (ColorList()
                          .randomColors
                          .where((color) => !isGreen(color))
                          .toList()
                        ..shuffle())
                      .first,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CustomCacheImage(
                        imageUrl: d.thumbnailUrl,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              d.name!.toUpperCase(),
                              style: _textStyleLarge.copyWith(
                                color: Colors.white,
                                fontSize: isCompact ? 16 : null,
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w700),
                              ),
                              overflow: TextOverflow.ellipsis,
                              // textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // QR Clickeable con animación
            if (qrInfo != null)
              Positioned(
                top: 12,
                right: 12,
                child: PulsingQRButton(
                  onTap: () => _launchQrUrl(qrInfo['redirect']!),
                  child: Container(
                    width: qrSize,
                    height: qrSize,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.network(
                        qrInfo['image']!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.qr_code,
                            color: Colors.black87,
                            size: qrSize * 0.8,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool isGreen(Color color) {
    return color.green > color.red && color.green > color.blue;
  }
}

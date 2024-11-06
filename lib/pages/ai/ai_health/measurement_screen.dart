import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/pages/profile.dart';
import 'package:travel_hour/widgets/gradient_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({Key? key}) : super(key: key);

  @override
  _MeasurementScreenState createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  String lang = 'es';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtener el idioma del contexto
    lang = context.locale.languageCode;

    //print(lang);
  }

  // Función para abrir enlaces
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el enlace: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = context.read<SignInBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sb.uid == null || sb.uid!.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('you_have_not_logged_in').tr(),
              content: const Text(
                'you_must_log_in_to_access_this_feature',
              ).tr(),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(20)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: const Text('Sign In with Google').tr(),
                ),
              ],
            );
          },
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo_1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: const EdgeInsets.all(8),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mostrar imagen solo si el usuario ha iniciado sesión
              if (sb.uid != null && sb.uid!.isNotEmpty)
                // Expanded(
                //   child: Center(
                //     child: Image.network(
                //       'https://media.experienciaquindio.com/uploads/2024/09/app/ia_options/toma_signos_instrucciones.png',
                //       fit: BoxFit.contain,
                //     ),
                //   ),
                // )
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/instructions_$lang.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      'please_log_in_to_see_the_instructions',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).tr(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    GradientButton(
                      label: 'Google Play',
                      icon: Icons.android,
                      onPressed: () {
                        _launchURL(
                            'https://play.google.com/store/search?q=gmdvita');
                      },
                      gradientColors: [
                        Colors.black,
                        Colors.black,
                      ],
                    ),
                    GradientButton(
                      label: 'App Store',
                      icon: Icons.apple,
                      onPressed: () {
                        _launchURL('https://www.apple.com/app-store/');
                      },
                      gradientColors: [
                        Colors.black,
                        Colors.black,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

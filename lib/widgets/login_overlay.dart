import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/pages/profile.dart';
import 'package:travel_hour/utils/app_colors.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class LoginOverlay extends StatelessWidget {
  final VoidCallback onSessionChecked;

  const LoginOverlay({
    Key? key,
    required this.onSessionChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Container(
      color: Colors.transparent,
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Botón X para cerrar
                Positioned(
                  right: -10,
                  top: -10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Contenido del modal
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Feather.user_plus,
                      size: 50,
                      color: CustomColors.primaryColor,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'you_should_log_in',
                      style: _textStyleLarge.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).tr(),
                    SizedBox(height: 10),
                    Text(
                      'log_in_to_chat',
                      style: _textStyleMedium.copyWith(
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ).tr(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        if (sp.getString('uid') != null) {
                          Navigator.pop(context); // Cerramos el overlay
                          onSessionChecked(); // Actualizamos el estado de la sesión
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.login),
                          SizedBox(width: 8),
                          Text(
                            'login',
                            style: TextStyle(fontSize: 16),
                          ).tr(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
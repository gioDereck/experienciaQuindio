import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/config/config.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class LanguagePopup extends StatefulWidget {
  const LanguagePopup({Key? key}) : super(key: key);

  @override
  _LanguagePopupState createState() => _LanguagePopupState();
}

class _LanguagePopupState extends State<LanguagePopup> {
  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('select language', style: _textStyleMedium).tr(),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: Config().languages.length,
        itemBuilder: (BuildContext context, int index) {
          return _itemList(Config().languages[index], index);
        },
      ),
    );
  }

  Widget _itemList(d, index) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    String language = context.locale.languageCode;

    return Column(
      children: [
        ListTile(
          leading: Icon(LineIcons.language),
          title: Text(
            easy.tr('${d}'),
            style: _textStyleMedium,
          ),
          // Uso de Row para alinear el título y el círculo verde
          trailing: (d == 'English' && language == 'en') ||
                  (d == 'Spanish' && language == 'es') ||
                  (d == 'French' && language == 'fr')
              ? Icon(Icons.circle,
                  color: Colors.green, size: 12) // Círculo verde
              : SizedBox
                  .shrink(), // Espacio vacío si no es el idioma seleccionado
          onTap: () async {
            // Cambiar el idioma seleccionado
            if (d == 'English') {
              await context.setLocale(Locale('en'));
            } else if (d == 'Spanish') {
              await context.setLocale(Locale('es'));
            } else if (d == 'French') {
              await context.setLocale(Locale('fr'));
            }

            Navigator.pop(context); // Cerrar el diálogo
          },
        ),
        Divider(
          height: 5,
          color: Colors.grey[400],
        )
      ],
    );
  }
}

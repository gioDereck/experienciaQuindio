import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreeniOS(context, page) {
  Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
}

void nextScreenCloseOthers(context, page) {
  Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => page), (route) => false);
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenPopup(context, page) {
  Navigator.push(
    context,
    MaterialPageRoute(fullscreenDialog: true, builder: (context) => page),
  );
}

void nextScreenGoNamedWithOptions(
  BuildContext context,
  String name, {
  Map<String, String> pathParameters = const <String, String>{},
  Map<String, dynamic> queryParameters = const <String, dynamic>{},
  Object? extra,
}) {
  context.goNamed(name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra);
}

// Nuevas funciones para navegación con go_router
void nextScreenGoNamed(BuildContext context, String routeName) {
  context.goNamed(routeName);
}

// Navegar a la ruta con datos extra
void nextScreenGoWithExtra(
    BuildContext context, String routeName, Object extra) {
  context.goNamed(routeName, extra: extra);
}

// Navegar y reemplazar la ruta actual
void nextScreenGoReplace(BuildContext context, String routeName, Object extra) {
  context.go(routeName, extra: extra);
}

// Navegar con animación de diálogo a pantalla completa
void nextScreenPushNamed(BuildContext context, String routeName) {
  context.pushNamed(routeName);
}

// Regresar a la pantalla anterior
void nextScreenPop(BuildContext context) {
  context.pop();
}

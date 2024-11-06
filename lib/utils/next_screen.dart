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
void nextScreenGo(BuildContext context, String path) {
  context.go(path);
}

// Navegar con animación de diálogo a pantalla completa
void nextScreenPushNamed(BuildContext context, String routeName) {
  context.pushNamed(routeName);
}

// Regresar a la pantalla anterior
void nextScreenPop(BuildContext context) {
  context.pop();
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/config/config.dart';

import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/blocs/gps/gps_bloc.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;

  afterSplash() {
    final SignInBloc sb = context.read<SignInBloc>();
    Future.delayed(Duration(milliseconds: 1200)).then((value) {
      sb.isSignedIn == true || sb.guestUser == true
          ? gotoHomePage()
          : gotoSignInPage();
    });
  }

  gotoHomePage() {
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.isSignedIn == true) {
      sb.getDataFromSp();
    }
    // nextScreenReplace(context, HomePage());
    nextScreenGoNamed(context, "explore");
  }

  gotoSignInPage() {
    // nextScreenReplace(context, SignInPage());
    nextScreenGoNamed(context, "sig-in");
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
    afterSplash();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child: BlocBuilder<GpsBloc, GpsState>(
        builder: (context, state) {
          // Mostramos la imagen con rotación
          return RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: Image(
                image: AssetImage(Config().splashIcon),
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ));
        },
      ),
    ));
  }
}

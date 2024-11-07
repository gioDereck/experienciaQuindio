import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/pages/qr_code.dart';
import 'package:travel_hour/services/navigation_service.dart';

class Header extends StatelessWidget {
  final bool withoutSearch;
  const Header({Key? key, required this.withoutSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = Provider.of<SignInBloc>(context);
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    NavigationService().navigateToIndex(0);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 5, bottom: 3),
                        child: Image.asset(
                          'assets/images/logo_home.png',
                          height: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(FontAwesome.qrcode,
                            size: 28, color: Theme.of(context).primaryColor),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QrCodePage()),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    InkWell(
                        child: sb.imageUrl == null || sb.isSignedIn == false
                            ? Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD843),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            sb.imageUrl!),
                                        fit: BoxFit.cover)),
                              ),
                        onTap: () {
                          NavigationService().navigateToIndex(4);
                        }),
                  ],
                ),
              ],
            ),
          ),
          //(withoutSearch ? Container() : SearchButton())
        ],
      ),
    );
  }
}

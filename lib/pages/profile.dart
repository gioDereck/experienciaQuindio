import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/blocs/notification_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/pages/edit_profile.dart';
// import 'package:travel_hour/pages/notifications.dart';
import 'package:travel_hour/pages/privacy_policy_page.dart';
import 'package:travel_hour/pages/security.dart';
import 'package:travel_hour/pages/sign_in.dart';
import 'package:travel_hour/services/app_service.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/image_view.dart';
import 'package:travel_hour/widgets/language.dart';
import 'package:get/get.dart';
import 'package:travel_hour/widgets/notification_icon.dart';
import 'package:travel_hour/widgets/webView.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  bool hasNewNotification = false;
  bool atleastOnce = false;
  String lang = '';
  SharedPreferences? sp;
  bool? notificationsEnabled;

  openAboutDialog() {
    final sb = context.read<SignInBloc>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationName: Config().appName,
            applicationIcon: Image(
              image: AssetImage(Config().splashIcon),
              height: 30,
              width: 30,
            ),
            applicationVersion: sb.appVersion,
          );
        });
  }

  // Chequea una unica vez las nuevas notificaciones
  @override
  void initState() {
    super.initState();
    _loadData(); // Llamamos a un método que carga los datos.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lang = context.locale.languageCode;
    _refreshNotificationState();
  }

  Future<void> _refreshNotificationState() async {
    if (sp == null) {
      sp = await SharedPreferences.getInstance();
    }
    bool currentState = sp?.getBool('notificationsEnabled') ?? false;
    if (currentState != notificationsEnabled) {
      setState(() {
        notificationsEnabled = currentState;
      });
    }
  }

  // Método asíncrono que carga los datos.
  Future<void> _loadData() async {
    sp = await SharedPreferences.getInstance();
    String? _uid = sp?.getString('uid');
    List<String> savedTimestamps = [];

    notificationsEnabled = sp?.getBool('notificationsEnabled') ?? false;

    if (_uid != null) {
      String? bru = sp?.getString('notifications_' + _uid);
      savedTimestamps = bru?.split(',') ?? [];
    }

    final nb = context.read<NotificationBloc>();
    await nb.getData(mounted, context);

    if (nb.data.isNotEmpty) {
      for (var notification in nb.data) {
        if (!savedTimestamps.contains(notification.timestamp)) {
          setState(() => hasNewNotification = true);
          break;
        }
      }
    }

    // Utiliza hasNewNotification como sea necesario
    //print('¿Hay nuevas notificaciones? $hasNewNotification');
  }

  Future<void> _handleNotificationToggle(bool newValue) async {
    setState(() => notificationsEnabled = newValue);
    await sp?.setBool('notificationsEnabled', newValue);
    if (mounted) {
      context
          .read<NotificationBloc>()
          .handleSubscription(context, newValue, sp);
    }
  }

  String appendLangParameter(String url) {
    int index = url.lastIndexOf('.html');
    if (index != -1) {
      return url.substring(0, index) + '_$lang' + url.substring(index);
    }
    return url; // Devuelve la URL original si no encuentra ".html"
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final FontSizeController fontSizeController =
        Get.find<FontSizeController>();
    var baseStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight:
              fontSizeController.obtainContrastFromBase(FontWeight.w600),
        );
    TextStyle _textStyle = baseStyle.copyWith(
      color: Colors.grey[900],
    );
    final sb = context.watch<SignInBloc>();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'profile',
            style: _textStyle,
          ).tr(),
          centerTitle: false,
          actions: [
            NotificationIcon(
              hasNewNotification: hasNewNotification,
              onPressed: () {
                setState(() {
                  hasNewNotification = false;
                });
                // nextScreen(context, NotificationsPage());
                nextScreenGoNamed(context, 'notifications');
              },
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 50),
          children: [
            sb.isSignedIn == false ? GuestUserUI() : UserUI(),
            Text("general setting",
                style: _textStyle.copyWith(
                  fontWeight: fontSizeController
                      .obtainContrastFromBase(FontWeight.w800),
                )).tr(),
            SizedBox(
              height: 15,
            ),
            ListTile(
              title: Text('get notifications', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.bell, size: 20, color: Colors.white),
              ),
              trailing: Switch.adaptive(
                  activeColor: Theme.of(context).primaryColor,
                  value: notificationsEnabled ?? false,
                  onChanged: _handleNotificationToggle),
            ),
            Divider(height: 5),
            ListTile(
              title: Text('font', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Icons.text_fields, size: 20, color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(
                      size: 25,
                      color: Colors.black87,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        fontSizeController.increaseFontSize();
                      },
                    ),
                  ),
                  IconTheme(
                    data: IconThemeData(
                      size: 25,
                      color: Colors.black87,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        fontSizeController.decreaseFontSize();
                      },
                    ),
                  ),
                  IconTheme(
                    data: IconThemeData(
                      size: 25,
                      color: Colors.black87,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.restore),
                      onPressed: () {
                        fontSizeController.resetFontSize();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 5),
            ListTile(
              title: Text('contrast', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 68, 96, 255),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Icons.contrast, size: 20, color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(
                      size: 25,
                      color: Colors.black87,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        fontSizeController.increaseFontContrast();
                      },
                    ),
                  ),
                  IconTheme(
                    data: IconThemeData(
                      size: 25,
                      color: Colors.black87,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        fontSizeController.decreaseFontContrast();
                      },
                    ),
                  ),
                  IconTheme(
                    data: IconThemeData(
                      size: 25,
                      color: Colors.black87,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.restore),
                      onPressed: () {
                        fontSizeController.resetFontContrast();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 5),
            ListTile(
              title: Text('language', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.globe, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () {
                // nextScreenPopup(context, LanguagePopup())
                nextScreenGoNamed(context, 'languages');
              },
            ),
            Divider(
              height: 5,
            ),
            ListTile(
              title: Text('contact us', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.mail, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () async => await AppService().openEmailSupport(context),
            ),
            Divider(
              height: 5,
            ),
            ListTile(
              title: Text('privacy policy', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.lock, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () {
                // final String updatedUrl =
                //     appendLangParameter(Config().privacyPolicyUrl);
                // AppService().openLinkWithCustomTab(context, updatedUrl);
                final String updatedUrl =
                    appendLangParameter(Config().privacyPolicyUrl);

                nextScreenGoNamedWithOptions(context, 'privacy_policy',
                    pathParameters: {}, queryParameters: {'url': updatedUrl});

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => PrivacyPolicyPage(
                //       url: updatedUrl,
                //     ),
                //   ),
                // );
              },
            ),
            Divider(
              height: 5,
            ),
            ListTile(
              title: Text('about us', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.star, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () {
                nextScreenGoNamedWithOptions(context, 'survey',
                    pathParameters: {
                      'url': Config().yourWebsiteUrl,
                      'label': easy.tr('rate this app')
                    },
                    queryParameters: {});
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => WebView(
                //             url: Config().yourWebsiteUrl,
                //             label: easy.tr('rate this app'))));
              },
            ),
            sb.guestUser == true
                ? Container()
                : SecurityOption(
                    textStyle: _textStyle,
                  ),
            Divider(
              height: 10,
            ),
            ListTile(
              title: Text('facebook', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.facebook, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () =>
                  AppService().openLink(context, Config().facebookPageUrl),
            ),
            Divider(
              height: 10,
            ),
            ListTile(
              title: Text('youtube', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: Icon(Feather.youtube, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () =>
                  AppService().openLink(context, Config().youtubeChannelUrl),
            ),
            Divider(
              height: 10,
            ),
            ListTile(
              title: Text('instagram', style: _textStyle).tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF833AB4), // Morado
                      Color(0xFFF77737), // Naranja
                      Color(0xFFE1306C), // Rojo-rosado
                      Color(0xFFC13584), // Magenta
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Feather.instagram, size: 20, color: Colors.white),
              ),
              trailing: Icon(
                Feather.chevron_right,
                size: 20,
              ),
              onTap: () =>
                  AppService().openLink(context, Config().instagramUrl),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class SecurityOption extends StatelessWidget {
  const SecurityOption({Key? key, required this.textStyle}) : super(key: key);
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 10,
        ),
        ListTile(
          title: Text('security', style: textStyle).tr(),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.blueGrey, borderRadius: BorderRadius.circular(5)),
            child: Icon(Feather.settings, size: 20, color: Colors.white),
          ),
          trailing: Icon(
            Feather.chevron_right,
            size: 20,
          ),
          onTap: () => nextScreen(context, SecurityPage()),
        ),
      ],
    );
  }
}

class GuestUserUI extends StatelessWidget {
  const GuestUserUI({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final FontSizeController fontSizeController =
        Get.find<FontSizeController>();
    var baseStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight:
              fontSizeController.obtainContrastFromBase(FontWeight.w500),
        );
    TextStyle _textStyle = baseStyle.copyWith(
      color: Colors.grey[900],
    );

    return Column(
      children: [
        ListTile(
            title: Text(
              'login',
              style: _textStyle,
            ).tr(),
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(5)),
              child: Icon(Feather.user, size: 20, color: Colors.white),
            ),
            trailing: Icon(
              Feather.chevron_right,
              size: 20,
            ),
            onTap: () => {
                  // nextScreenPopup(
                  //     context,
                  //     SignInPage(
                  //       tag: 'popup',
                  //     )),
                  nextScreenGoNamed(context, 'sig-in')
                }),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class UserUI extends StatelessWidget {
  const UserUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FontSizeController fontSizeController =
        Get.find<FontSizeController>();
    var baseStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight:
              fontSizeController.obtainContrastFromBase(FontWeight.w500),
        );
    TextStyle _textStyle = baseStyle.copyWith(
      color: Colors.grey[900],
    );
    final sb = context.watch<SignInBloc>();

    return Column(
      children: [
        Container(
          height: 200,
          child: Column(
            children: [
              InkWell(
                child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: CachedNetworkImageProvider(sb.imageUrl!)),
                onTap: () => nextScreen(
                    context, FullScreenImage(imageUrl: sb.imageUrl!)),
              ),
              SizedBox(
                height: 10,
              ),
              Text(sb.name!,
                  style: _textStyle.copyWith(
                      fontWeight: fontSizeController
                          .obtainContrastFromBase(FontWeight.bold),
                      letterSpacing: -0.6,
                      wordSpacing: 2))
            ],
          ),
        ),
        ListTile(
          title: Text(
            sb.email!,
            style: _textStyle,
          ),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(Feather.mail, size: 20, color: Colors.white),
          ),
        ),
        Divider(
          height: 5,
        ),
        ListTile(
          title: Text(
            sb.joiningDate!,
            style: _textStyle,
          ),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(5)),
            child: Icon(LineIcons.timesCircle, size: 20, color: Colors.white),
          ),
        ),
        Divider(
          height: 5,
        ),
        ListTile(
            title: Text(
              'edit profile',
              style: _textStyle,
            ).tr(),
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(5)),
              child: Icon(Feather.edit_3, size: 20, color: Colors.white),
            ),
            trailing: Icon(
              Feather.chevron_right,
              size: 20,
            ),
            onTap: () => nextScreen(
                context,
                EditProfile(
                    name: sb.name,
                    imageUrl: sb.imageUrl,
                    phone: sb.phone,
                    department: sb.department,
                    city: sb.city,
                    address: sb.address,
                    eps: sb.eps,
                    age: sb.age,
                    gender: sb.gender,
                    occupation: sb.occupation,
                    password: sb.password))),
        Divider(
          height: 5,
        ),
        ListTile(
          title: Text(
            'logout',
            style: _textStyle,
          ).tr(),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5)),
            child: Icon(Feather.log_out, size: 20, color: Colors.white),
          ),
          trailing: Icon(
            Feather.chevron_right,
            size: 20,
          ),
          onTap: () => openLogoutDialog(context),
        ),
        SizedBox(
          height: 15,
        )
      ],
    );
  }

  void openLogoutDialog(context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('logout title', style: _textStyleMedium).tr(),
            actions: [
              TextButton(
                child: Text('no', style: _textStyleMedium).tr(),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('yes', style: _textStyleMedium).tr(),
                onPressed: () async {
                  Navigator.pop(context);
                  await context
                      .read<SignInBloc>()
                      .userSignout()
                      .then((value) =>
                          context.read<SignInBloc>().afterUserSignOut())
                      .then((value) =>
                          nextScreenCloseOthers(context, SignInPage()));
                },
              )
            ],
          );
        });
  }
}

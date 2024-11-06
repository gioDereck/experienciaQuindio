import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/blocs/notification_bloc.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/models/notification.dart';
import 'package:travel_hour/services/app_service.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'notification_details.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  ScrollController? controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      context.read<NotificationBloc>().onRefresh(mounted, context);
      _saveNotificationsSeen();
    });
  }

  Future<void> _saveNotificationsSeen() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');

    if (_uid != null) {
      final nb = context.read<NotificationBloc>();
      await nb.getData(mounted, context);

      List<String> timestamps = [];
      for (var not in nb.data) {
        if (not.timestamp != null) {
          timestamps.add(not.timestamp!);
        }
      }

      String timestampsString = timestamps.join(',');
      sp.setString('notifications_' + _uid, timestampsString);
    }
  }

  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    final db = context.read<NotificationBloc>();

    if (!db.isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        context.read<NotificationBloc>().setLoading(true);
        context.read<NotificationBloc>().getData(mounted, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nb = context.watch<NotificationBloc>();

    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(easy.tr('notifications'), style: _textStyleMedium),
        actions: [
          IconButton(
            icon: Icon(
              Feather.rotate_cw,
              size: 22,
            ),
            onPressed: () =>
                context.read<NotificationBloc>().onReload(mounted, context),
          )
        ],
      ),
      body: RefreshIndicator(
        child: nb.hasData == false
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                  EmptyPage(
                      icon: Feather.bell_off,
                      message: easy.tr('no notifications'),
                      message1: ''),
                ],
              )
            : ListView.separated(
                padding: EdgeInsets.only(top: 15, bottom: 20),
                controller: controller,
                physics: AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: nb.data.length + 1,
                separatorBuilder: (context, index) => SizedBox(
                  height: 10,
                ),
                itemBuilder: (_, int index) {
                  if (index < nb.data.length) {
                    return _ListItem(d: nb.data[index]);
                  }
                  return Center(
                    child: new Opacity(
                      opacity: nb.isLoading ? 1.0 : 0.0,
                      child: new SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: new CircularProgressIndicator()),
                    ),
                  );
                },
              ),
        onRefresh: () async {
          context.read<NotificationBloc>().onRefresh(mounted, context);
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final NotificationModel d;
  const _ListItem({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    final translator = GoogleTranslator();
    Future<String>? _translatedTitle;
    Future<String>? _translatedDescription;

    String title = d.title!.toString();
    String descriptionNature =
        AppService.getNormalText(d.description.toString());

    _translatedTitle = translator
        .translate(title, from: 'auto', to: context.locale.languageCode)
        .then((result) => result.text)
        .catchError((error) {
      print('Translation error: $error');
      return title;
    });

    _translatedDescription = translator
        .translate(descriptionNature,
            from: 'auto', to: context.locale.languageCode)
        .then((result) => result.text)
        .catchError((error) {
      print('Translation error: $error');
      return descriptionNature;
    });

    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey[100]!, blurRadius: 5, offset: Offset(0, 3))
        ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 5,
              constraints: BoxConstraints(minHeight: 140),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _translatedTitle,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[400]!),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _textStyleLarge.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w600)),
                          );
                        }
                        d.title = snapshot.data;
                        return Text(
                          d.title ?? title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: _textStyleLarge.copyWith(
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.w600)),
                        );
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    FutureBuilder<String>(
                      future: _translatedDescription,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[400]!),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            descriptionNature,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _textStyleMedium.copyWith(
                                fontWeight: fontSizeController
                                    .obtainContrastFromBase(FontWeight.w500),
                                color: Colors.blueGrey[600]),
                          );
                        }
                        return Text(
                          snapshot.data ?? descriptionNature,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _textStyleMedium.copyWith(
                              fontWeight: fontSizeController
                                  .obtainContrastFromBase(FontWeight.w500),
                              color: Colors.blueGrey[600]),
                        );
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.time_solid,
                            size: 16, color: Colors.grey),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          d.createdAt,
                          style: _textStyleMedium.copyWith(color: Colors.grey),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () => nextScreen(context, NotificationDetails(data: d)),
    );
  }
}

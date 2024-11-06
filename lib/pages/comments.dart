import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/comments_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/models/comment.dart';
import 'package:travel_hour/services/app_service.dart';
import 'package:travel_hour/utils/dialog.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:travel_hour/utils/sign_in_dialog.dart';
import 'package:travel_hour/utils/toast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class CommentsPage extends StatefulWidget {
  final String collectionName;
  final String? timestamp;
  const CommentsPage(
      {Key? key, required this.collectionName, required this.timestamp})
      : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = [];
  List<Comment> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var textCtrl = TextEditingController();
  bool? _hasData;

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    setState(() => _hasData = true);
    await context.read<CommentsBloc>().getFlagList();
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection('${widget.collectionName}/${widget.timestamp}/comments')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection('${widget.collectionName}/${widget.timestamp}/comments')
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible!['timestamp']])
          .limit(10)
          .get();

    if (data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Comment.fromFirestore(e)).toList();
          debugPrint('blog reviews : ${_data.length}');
        });
      }
    } else {
      if (_lastVisible == null) {
        setState(() {
          _isLoading = false;
          _hasData = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasData = true;
        });
      }
    }
    return null;
  }

  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  openPopupDialog(Comment d) {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(20),
            children: [
              context.watch<CommentsBloc>().flagList.contains(d.timestamp)
                  ? Container()
                  : ListTile(
                      title: Text('flag this comment', style: _textStyleMedium)
                          .tr(),
                      leading: Icon(Icons.flag),
                      onTap: () async {
                        await context
                            .read<CommentsBloc>()
                            .addToFlagList(context, d.timestamp)
                            .then((value) => onRefreshData());
                        Navigator.pop(context);
                      },
                    ),
              context.watch<CommentsBloc>().flagList.contains(d.timestamp)
                  ? ListTile(
                      title:
                          Text('unflag this comment', style: _textStyleMedium)
                              .tr(),
                      leading: Icon(Icons.flag_outlined),
                      onTap: () async {
                        await context
                            .read<CommentsBloc>()
                            .removeFromFlagList(context, d.timestamp)
                            .then((value) => onRefreshData());
                        Navigator.pop(context);
                      },
                    )
                  : Container(),
              ListTile(
                title: Text('report', style: _textStyleMedium).tr(),
                leading: Icon(Icons.report),
                onTap: () {
                  handleReport(d);
                },
              ),
              sb.uid == d.uid
                  ? ListTile(
                      title: Text('delete', style: _textStyleMedium).tr(),
                      leading: Icon(Icons.delete),
                      onTap: () => handleDelete1(d),
                    )
                  : Container()
            ],
          );
        });
  }

  Future handleReport(Comment d) async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    if (sb.isSignedIn == true) {
      await context.read<CommentsBloc>().reportComment(
          widget.collectionName, widget.timestamp, d.uid, d.timestamp);
      Navigator.pop(context);
      openDialog(context, easy.tr('report-info'), easy.tr("report-info1"));
    } else {
      Navigator.pop(context);
      openDialog(context, easy.tr('report-guest'), easy.tr('report-guest1'));
    }
  }

  Future handleDelete1(Comment d) async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        Navigator.pop(context);
        openToast(context, easy.tr('no internet'));
      } else {
        await context
            .read<CommentsBloc>()
            .deleteComment(
                widget.collectionName, widget.timestamp, sb.uid, d.timestamp)
            .then((value) => openToast(context, 'Deleted Successfully!'));
        onRefreshData();
        Navigator.pop(context);
      }
    });
  }

  Future updateData(sb) async {
    context
        .read<CommentsBloc>()
        .saveNewComment(widget.collectionName, widget.timestamp, textCtrl.text);
    onRefreshData();
    textCtrl.clear();
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Future handleSubmit() async {
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.guestUser == true) {
      openSignInDialog(context);
    } else if (textCtrl.text.isEmpty) {
      debugPrint('Comment is empty');
    } else {
      if (kIsWeb) {
        updateData(sb);
      } else {
        bool? hasInternet = await AppService().checkInternet();
        if (hasInternet!) {
          openToast(context, easy.tr('no internet'));
        } else {
          updateData(sb);
        }
      }
    }
  }

  onRefreshData() {
    setState(() {
      _isLoading = true;
      _snap.clear();
      _data.clear();
      _lastVisible = null;
    });
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
                widget.collectionName == 'places' ? 'user reviews' : 'comments',
                style: _textStyleMedium)
            .tr(),
        titleSpacing: 0,
        actions: [
          IconButton(
              icon: Icon(
                Feather.rotate_cw,
                size: 22,
              ),
              onPressed: () => onRefreshData())
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              child: _hasData == false
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
                        EmptyPage(
                            icon: LineIcons.comments,
                            message: easy.tr('no comments found'),
                            message1: easy.tr('be the first to comment')),
                      ],
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(15),
                      controller: controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _data.length != 0 ? _data.length + 1 : 10,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (_, int index) {
                        if (index < _data.length) {
                          return reviewList(_data[index]);
                        }
                        return Opacity(
                          opacity: _isLoading ? 1.0 : 0.0,
                          child: _lastVisible == null
                              ? LoadingCard(height: 100)
                              : Center(
                                  child: SizedBox(
                                      width: 32.0,
                                      height: 32.0,
                                      child: new CupertinoActivityIndicator()),
                                ),
                        );
                      },
                    ),
              onRefresh: () async {
                onRefreshData();
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.black26,
          ),
          SafeArea(
            child: Container(
              height: 65,
              padding: EdgeInsets.only(top: 8, bottom: 10, right: 20, left: 20),
              width: double.infinity,
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25)),
                child: TextFormField(
                  decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: 0),
                      contentPadding:
                          EdgeInsets.only(left: 15, top: 10, right: 5),
                      border: InputBorder.none,
                      hintText: widget.collectionName == 'places'
                          ? easy.tr('write a review')
                          : easy.tr('write a comment'),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        onPressed: () {
                          handleSubmit();
                        },
                      )),
                  controller: textCtrl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reviewList(Comment d) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              backgroundImage: CachedNetworkImageProvider(d.imageUrl!)),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(d.name!,
                    style: _textStyleMedium.copyWith(
                      color: Colors.black,
                      fontWeight: fontSizeController
                          .obtainContrastFromBase(FontWeight.w700),
                    )),
              ),
              SizedBox(
                width: 10,
              ),
              Text(d.date!,
                  style: _textStyleMedium.copyWith(
                    color: Colors.grey[500],
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.w500),
                  ))
            ],
          ),
          subtitle: context.read<CommentsBloc>().flagList.contains(d.timestamp)
              ? Text('comment flagged', style: _textStyleMedium).tr()
              : Text(d.comment!,
                  style: _textStyleLarge.copyWith(
                    color: Colors.black54,
                    fontWeight: fontSizeController
                        .obtainContrastFromBase(FontWeight.w500),
                  )),
          onLongPress: () {
            openPopupDialog(d);
          },
        ));
  }
}

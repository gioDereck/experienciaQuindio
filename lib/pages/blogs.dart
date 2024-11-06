import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/blocs/blog_bloc.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/pages/blog_details.dart';
import 'package:travel_hour/services/app_service.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/utils/loading_cards.dart';

import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class BlogPage extends StatefulWidget {
  BlogPage({Key? key}) : super(key: key);
  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController? controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _orderBy = 'loves';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      controller = new ScrollController()..addListener(_scrollListener);
      context.read<BlogBloc>().getData(mounted, _orderBy);
    });
  }

  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    final db = context.read<BlogBloc>();
    if (!db.isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        context.read<BlogBloc>().setLoading(true);
        context.read<BlogBloc>().getData(mounted, _orderBy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bb = context.watch<BlogBloc>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text('blogs', style: _textStyleMedium).tr(),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton(
              child: Icon(CupertinoIcons.sort_down),
              //initialValue: 'view',
              itemBuilder: (BuildContext context) {
                return <PopupMenuItem>[
                  PopupMenuItem(
                    child: Text('Most Recent', style: _textStyleMedium).tr(),
                    value: 'recent',
                  ),
                  PopupMenuItem(
                    child: Text('Most Popular', style: _textStyleMedium).tr(),
                    value: 'popular',
                  )
                ];
              },
              onSelected: (dynamic value) {
                setState(() {
                  if (value == 'popular') {
                    _orderBy = 'loves';
                  } else {
                    _orderBy = 'timestamp';
                  }
                });
                bb.afterPopSelection(value, mounted, _orderBy);
              }),
          IconButton(
            icon: Icon(
              Feather.rotate_cw,
              size: 22,
            ),
            onPressed: () {
              context.read<BlogBloc>().onRefresh(mounted, _orderBy);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        child: bb.hasData == false
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                  EmptyPage(
                      icon: Feather.clipboard,
                      message: easy.tr('no blogs'),
                      message1: ''),
                ],
              )
            : LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth >= 1000) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth >= 700) {
                  crossAxisCount = 2;
                }
                return GridView.builder(
                  padding: EdgeInsets.all(15),
                  controller: controller,
                  physics: AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    mainAxisExtent: 310, // Altura mínima inicial
                  ),
                  itemCount: bb.data.length != 0 ? bb.data.length + 1 : 5,
                  itemBuilder: (_, int index) {
                    if (index < bb.data.length) {
                      return LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: _ItemList(bodyContent: bb.data[index]),
                          ),
                        );
                      });
                    }
                    return Opacity(
                      opacity: bb.isLoading ? 1.0 : 0.0,
                      child: bb.lastVisible == null
                          ? LoadingCard(height: 250)
                          : Center(
                              child: SizedBox(
                                  width: 32.0,
                                  height: 32.0,
                                  child: CupertinoActivityIndicator()),
                            ),
                    );
                  },
                );
              }),
        onRefresh: () async {
          context.read<BlogBloc>().onRefresh(mounted, _orderBy);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ItemList extends StatefulWidget {
  final Blog bodyContent;
  const _ItemList({Key? key, required this.bodyContent}) : super(key: key);

  @override
  State<_ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<_ItemList> {
  String? _currentLanguage;
  Future<String>? _translatedTitle;
  Future<String>? _translatedDescription;
  final translator = GoogleTranslator();

  void _updateTranslation() {
    _currentLanguage = context.locale.languageCode;

    String title = widget.bodyContent.title!;
    _translatedTitle = translator
        .translate(title, from: 'es', to: _currentLanguage!)
        .then((result) => result.text)
        .catchError((error) {
          print('Translation error: $error');
          return title;
        });
    
    String description = AppService.getNormalText(widget.bodyContent.description.toString());
    _translatedDescription = translator
        .translate(description, from: 'es', to: _currentLanguage!)
        .then((result) => result.text)
        .catchError((error) {
          print('Translation error: $error');
          return description;
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar si el idioma ha cambiado
    if (_currentLanguage != context.locale.languageCode) {
      _updateTranslation();
    }
  }

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();

    List<String> splitDate = widget.bodyContent.date!.split(" ");
    splitDate[1] = easy.tr(splitDate[1]);
    String formattedDate = "${splitDate[0]} ${splitDate[1]} ${splitDate[2]}";

    //  _textStyleMedium.copyWith
    double fontSizeMedium = fontSizeController.fontSizeMedium.value < 22 ? fontSizeController.fontSizeMedium.value : 20;
    double fontSizeTiny = fontSizeController.fontSizeTiny.value < 20 ? fontSizeController.fontSizeTiny.value : 18;

    return InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[200]!,
                    blurRadius: 10,
                    offset: Offset(0, 3))
              ]),
          child: Wrap(
            children: [
              Hero(
                tag: 'blog${widget.bodyContent.timestamp}',
                child: Container(
                  height: 160,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CustomCacheImage(
                          imageUrl: widget.bodyContent.thumbnailImagelUrl)),
                ),
              ),
            Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: _translatedTitle,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          widget.bodyContent.title!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(  // _textStyleMedium.copyWith
                            fontSize: fontSizeMedium,
                            fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w600)
                          ),
                        );
                      }
                      return Text(
                        snapshot.data ?? widget.bodyContent.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle( // _textStyleMedium.copyWith
                            fontSize: fontSizeMedium,
                            fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w600)
                          ),
                      );
                    },
                  ),
                  SizedBox(height: 5),
                  FutureBuilder<String>(
                    future: _translatedDescription,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                            ),
                          ));
                        } else if (snapshot.hasError) {
                          return Text(
                            AppService.getNormalText(widget.bodyContent.description.toString()),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle( // _textStyleMedium.copyWith
                                fontSize: fontSizeMedium,
                                fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w400),
                                color: Colors.grey[700]),
                          );
                        }
                        return Text(
                          snapshot.data ??
                              AppService.getNormalText(
                                  widget.bodyContent.description.toString()),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle( // _textStyleMedium.copyWith
                              fontSize: fontSizeMedium,
                              fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w400),
                              color: Colors.grey[700]),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.time, size: 16, color: Colors.grey),
                        SizedBox(width: 3),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: fontSizeTiny, color: Colors.grey),
                        ),
                        Spacer(),
                        Icon(Icons.favorite, size: 16, color: Colors.grey),
                        SizedBox(width: 3),
                        Text(
                          widget.bodyContent.loves.toString(),
                          style: TextStyle(fontSize: fontSizeTiny, color: Colors.grey),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () => nextScreen(
            context,
            BlogDetails(
                blogData: widget.bodyContent,
                tag: 'blog${widget.bodyContent.timestamp}')));
  }
}

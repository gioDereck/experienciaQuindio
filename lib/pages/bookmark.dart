import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:travel_hour/blocs/bookmark_bloc.dart';
import 'package:travel_hour/blocs/sign_in_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/models/blog.dart';
import 'package:travel_hour/pages/blog_details.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/list_card.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:travel_hour/utils/loading_cards.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final SignInBloc sb = context.watch<SignInBloc>();

    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('bookmarks', style: _textStyleMedium,).tr(),
          centerTitle: false,
          titleSpacing: 20,
          bottom: TabBar(
              labelPadding: EdgeInsets.only(left: 10, right: 10),
              indicatorColor: Theme.of(context).primaryColor,
              isScrollable: false,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[500],
              indicatorWeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
              indicator: MD2Indicator(
                indicatorHeight: 3,
                indicatorSize: MD2IndicatorSize.normal,
                indicatorColor: Theme.of(context).primaryColor,
              ),
              tabs: [
                Tab(
                  child: Container(
                    padding: EdgeInsets.only(left: 5, right: 0),
                    alignment: Alignment.centerLeft,
                    child: Text('saved places', style: _textStyleMedium,).tr(),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    alignment: Alignment.centerLeft,
                    child: Text('saved blogs', style: _textStyleMedium,).tr(),
                  ),
                )
              ]),
        ),
        body: TabBarView(children: <Widget>[
          sb.guestUser == true
              ? EmptyPage(
                  icon: Feather.user_plus,
                  message: easy.tr('sign in first'),
                  message1: easy.tr("sign in to save your favourite places here"),
                )
              : BookmarkedPlaces(),
          sb.guestUser == true
              ? EmptyPage(
                  icon: Feather.user_plus,
                  message: easy.tr('sign in first'),
                  message1: easy.tr("sign in to save your favourite blogs here"),
                )
              : BookmarkedBlogs(),
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BookmarkedPlaces extends StatefulWidget {
  const BookmarkedPlaces({Key? key}) : super(key: key);

  @override
  _BookmarkedPlacesState createState() => _BookmarkedPlacesState();
}

class _BookmarkedPlacesState extends State<BookmarkedPlaces>
    with AutomaticKeepAliveClientMixin {
  final String collectionName = 'hotels';
  final String type = 'bookmarked_hotels';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: FutureBuilder(
        future: context.watch<BookmarkBloc>().getPlaceData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            final places = context.watch<BookmarkBloc>().bookmarkedPlaces;
            if (places.isEmpty) {
              return EmptyPage(
                icon: Feather.bookmark,
                message: easy.tr('no places found'),
                message1: easy.tr('save your favourite places here'),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(5),
              itemCount: places.length,
              separatorBuilder: (context, index) => SizedBox(height: 5),
              itemBuilder: (BuildContext context, int index) {
                return ListCard(
                  d: places[index],
                  tag: "bookmark$index",
                  color: Colors.white,
                );
              },
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(15),
            itemCount: 5,
            separatorBuilder: (BuildContext context, int index) => SizedBox(
              height: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              return LoadingCard(height: 150);
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BookmarkedBlogs extends StatefulWidget {
  const BookmarkedBlogs({Key? key}) : super(key: key);

  @override
  _BookmarkedBlogsState createState() => _BookmarkedBlogsState();
}

class _BookmarkedBlogsState extends State<BookmarkedBlogs>
    with AutomaticKeepAliveClientMixin {
  final String collectionName = 'blogs';
  final String type = 'bookmarked_blogs';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: FutureBuilder(
        future: context.watch<BookmarkBloc>().getBlogData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0)
              return EmptyPage(
                icon: Feather.bookmark,
                message: easy.tr('no blogs found'),
                message1: easy.tr('save your favourite blogs here'),
              );
            else
              return ListView.separated(
                padding: EdgeInsets.all(15),
                itemCount: snapshot.data.length,
                separatorBuilder: (context, index) => SizedBox(
                  height: 15,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return _BlogList(data: snapshot.data[index]);
                },
              );
          }
          return ListView.separated(
            padding: EdgeInsets.all(15),
            itemCount: 5,
            separatorBuilder: (BuildContext context, int index) => SizedBox(
              height: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              return LoadingCard(height: 120);
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _BlogList extends StatelessWidget {
  final Blog? data;
  const _BlogList({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    FontSizeController fontSizeController = getx.Get.find<FontSizeController>();
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    List<String> parts = data!.date!.split(" ");
    parts[1] = easy.tr(parts[1]);
    String formattedDate = "${parts[0]} ${parts[1]} ${parts[2]}";

    return InkWell(
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(3)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Hero(
                  tag: 'bookmark${data!.timestamp}',
                  child: Container(
                    width: 140,
                    child: CustomCacheImage(imageUrl: data!.thumbnailImagelUrl),
                  )),
            ),
            Flexible(
              child: Container(
                margin:
                    EdgeInsets.only(left: 15, top: 15, right: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data!.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: _textStyleMedium.copyWith(
                        fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.w500),
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(CupertinoIcons.time,
                                size: 16, color: Colors.grey),
                            SizedBox(
                              width: 3,
                            ),
                            Text(formattedDate, style: _textStyleMedium.copyWith(color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite, size: 16, color: Colors.grey),
                            SizedBox(
                              width: 3,
                            ),
                            Text(data!.loves.toString(),
                                style: _textStyleMedium.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        nextScreen(context, BlogDetails(blogData: data, tag: 'bookmark${data!.timestamp}'));
      },
    );
  }
}

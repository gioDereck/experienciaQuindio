import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_hour/models/place.dart';
import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/services/navigation_service.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';
import 'package:travel_hour/widgets/header.dart';

class MorePlacesPage extends StatefulWidget {
  final String title;
  final Color? color;
  MorePlacesPage({Key? key, required this.title, required this.color})
      : super(key: key);

  @override
  _MorePlacesPageState createState() => _MorePlacesPageState();
}

class _MorePlacesPageState extends State<MorePlacesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'places';
  final int _pageSize = 15; // Increased page size for better performance
  final scrollController = ScrollController();

  DocumentSnapshot? _lastVisible;
  bool _isLoading = false;
  bool _hasMore = true;
  List<Place> _places = [];
  late String _orderBy;
  late bool _descending;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollController();
  }

  void _initializeData() {
    _orderBy = _getOrderByField();
    _descending = true;
    _loadMoreData();
  }

  String _getOrderByField() {
    switch (widget.title) {
      case 'popular':
        return 'loves';
      case 'recommended':
        return 'comments count';
      default:
        return 'timestamp';
    }
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (_shouldLoadMore()) {
        _loadMoreData();
      }
    });
  }

  bool _shouldLoadMore() {
    return scrollController.position.pixels >=
            scrollController.position.maxScrollExtent *
                0.8 && // Load when 80% scrolled
        !_isLoading &&
        _hasMore;
  }

  Future<void> _loadMoreData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final QuerySnapshot data = await _getNextBatch();
      final List<Place> newPlaces = _processQuerySnapshot(data);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (newPlaces.isNotEmpty) {
            final filteredPlaces = newPlaces.where((place) {
              return place.isDepartment == null &&
                  (_descending ? place.isState == true : place.isState == null);
            }).toList();

            _places.addAll(filteredPlaces);
            if (data.docs.isNotEmpty) {
              _lastVisible = data.docs.last;
            }
          } else {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      }
    }
  }

  Future<QuerySnapshot> _getNextBatch() {
    Query query = firestore
        .collection(collectionName)
        .orderBy(_orderBy, descending: _descending)
        .limit(_pageSize);

    if (_lastVisible != null) {
      query = query.startAfter([_lastVisible![_orderBy]]);
    }

    return query.get();
  }

  List<Place> _processQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _places.clear();
      _lastVisible = null;
      _hasMore = true;
    });
    await _loadMoreData();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildHeader(),
            _buildAppBar(context),
            _buildPlacesGrid(),
            if (_isLoading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Header(withoutSearch: true),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      actions: [
        IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () => NavigationService().navigateToIndex(0),
        )
      ],
      backgroundColor: widget.color,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        background: Container(
          color: widget.color,
          height: 120,
          width: double.infinity,
        ),
        title: Text(
          '${widget.title} places',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ).tr(),
        titlePadding: EdgeInsets.only(left: 20, bottom: 15, right: 15),
      ),
    );
  }

  Widget _buildPlacesGrid() {
    return SliverPadding(
      padding: EdgeInsets.all(12),
      sliver: SliverLayoutBuilder(
        builder: (BuildContext context, SliverConstraints constraints) {
          int crossAxisCount =
              _calculateCrossAxisCount(constraints.crossAxisExtent);
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 290,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < _places.length) {
                  return _ListItem(
                    d: _places[index],
                    tag: '${widget.title}$index',
                  );
                }
                return null;
              },
              childCount: _places.length,
            ),
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width >= 1000) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  Widget _buildLoadingIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Place d;
  final String tag;
  const _ListItem({Key? key, required this.d, required this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return InkWell(
      onTap: () => nextScreen(
          context, PlaceDetails(data: d, tag: tag, itComeFromHome: false)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[200]!, blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag:
                  'morePlace_${d.timestamp}', // Usar un ID único basado en el timestamp
              child: Container(
                height: 160,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  child: CustomCacheImage(imageUrl: d.imageUrl1),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name!,
                    maxLines: 1,
                    style: _textStyleLarge.copyWith(
                      fontWeight: fontSizeController
                          .obtainContrastFromBase(FontWeight.w600),
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Feather.map_pin, size: 14, color: Colors.grey),
                      SizedBox(width: 3),
                      Expanded(
                          child: Text(d.location!,
                              maxLines: 1,
                              style: _textStyleMedium.copyWith(
                                  color: Colors.grey[700]))),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(CupertinoIcons.time,
                          size: 14, color: Colors.grey[700]),
                      SizedBox(width: 3),
                      Text(d.date!,
                          style: _textStyleMedium.copyWith(
                              color: Colors.grey[700])),
                      Spacer(),
                      Icon(LineIcons.heart, size: 14, color: Colors.grey),
                      SizedBox(width: 3),
                      Text(d.loves.toString(),
                          style: _textStyleMedium.copyWith(
                              color: Colors.grey[700])),
                      SizedBox(width: 10),
                      Icon(LineIcons.comment, size: 14, color: Colors.grey),
                      SizedBox(width: 3),
                      Text(d.commentsCount.toString(),
                          style: _textStyleMedium.copyWith(
                              color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

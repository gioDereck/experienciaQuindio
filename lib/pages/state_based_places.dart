import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:translator/translator.dart';
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:travel_hour/models/place.dart';
// import 'package:travel_hour/pages/place_details.dart';
import 'package:travel_hour/utils/empty.dart';
import 'package:travel_hour/utils/next_screen.dart';
import 'package:travel_hour/widgets/contact_buttons.dart';
import 'package:travel_hour/widgets/custom_cache_image.dart';
import 'package:get/get.dart' as getx;
import 'package:easy_localization/easy_localization.dart' as easy;

class StateBasedPlaces extends StatefulWidget {
  final String? stateName;
  final Color? color;

  const StateBasedPlaces(
      {Key? key, required this.stateName, required this.color})
      : super(key: key);

  @override
  _StateBasedPlacesState createState() => _StateBasedPlacesState();
}

class _StateBasedPlacesState extends State<StateBasedPlaces> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'places';
  final int _pageSize = 10;
  final scrollController = ScrollController();

  DocumentSnapshot? _lastVisible;
  bool _isLoading = false;
  bool _hasMore = true;
  List<Place> _places = [];

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _loadMoreData();
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
            scrollController.position.maxScrollExtent * 0.8 &&
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
            _places.addAll(newPlaces);
            _lastVisible = data.docs.last;
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
        .where('state', isEqualTo: widget.stateName)
        .orderBy('loves', descending: true)
        .limit(_pageSize);

    if (_lastVisible != null) {
      query = query.startAfter([_lastVisible!['loves']]);
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
      floatingActionButton: ContactButtons(
        withoutAssistant: false,
        uniqueId: 'statePage',
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            _buildAppBar(context),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final TextStyle textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    final FontSizeController fontSizeController =
        getx.Get.find<FontSizeController>();

    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
          child: SafeArea(
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
              child: IconButton(
                icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
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
          widget.stateName!.toUpperCase(),
          style: textStyleMedium.copyWith(
            fontWeight:
                fontSizeController.obtainContrastFromBase(FontWeight.w700),
          ),
        ),
        titlePadding: EdgeInsets.only(left: 20, bottom: 15, right: 15),
      ),
    );
  }

  Widget _buildContent() {
    if (_places.isEmpty && !_hasMore) {
      return SliverFillRemaining(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.30),
            EmptyPage(
              icon: Feather.clipboard,
              message: easy.tr('no places found'),
              message1: '',
            ),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.all(15),
      sliver: SliverGrid(
        gridDelegate: _buildGridDelegate(),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < _places.length) {
              return _GridItem(
                d: _places[index],
                tag: '${_places[index].timestamp}$index',
              );
            }
            if (_isLoading) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }
            return null;
          },
          childCount: _places.length + (_isLoading ? 1 : 0),
        ),
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate() {
    final FontSizeController fontSizeController =
        getx.Get.find<FontSizeController>();
    final fontSizeBreakPoint = 22;
    final width = MediaQuery.of(context).size.width;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: width >= 1000
          ? 3
          : width >= 700
              ? 2
              : 1,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      mainAxisExtent:
          fontSizeController.fontSizeMedium.value > fontSizeBreakPoint
              ? width < 430
                  ? 390
                  : 370
              : 300,
    );
  }
}

class _GridItem extends StatefulWidget {
  final Place d;
  final String tag;

  const _GridItem({
    Key? key,
    required this.d,
    required this.tag,
  }) : super(key: key);

  @override
  State<_GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<_GridItem> {
  String? _currentLanguage;
  Future<String>? _translatedTitle;
  final translator = GoogleTranslator();

  void _initializeTranslation() {
    _currentLanguage = context.locale.languageCode;
    if (_currentLanguage != 'en') {
      _translatedTitle = translator
          .translate(
            widget.d.name!,
            from: 'en',
            to: _currentLanguage!,
          )
          .then((result) => result.text);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentLanguage != context.locale.languageCode) {
      _initializeTranslation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final FontSizeController fontSizeController =
        getx.Get.find<FontSizeController>();
    final TextStyle textStyleMedium = Theme.of(context).textTheme.bodyMedium!;
    final fontSizeBreakPoint = 22;
    final formattedDate = _formatDate(widget.d.date!, context);

    return InkWell(
      onTap: () => nextScreenGoWithExtra(
        context,
        'place-details',
        {
          'data': widget.d,
          'tag': widget.tag,
          'itComeFromHome': false,
          'previous_route': 'home'
        },
      ),
      // nextScreen(
      //   context,
      //   PlaceDetails(data: widget.d, tag: widget.tag, itComeFromHome: false),
      // ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildImage(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTranslatedTitle(
                        fontSizeController, fontSizeBreakPoint),
                    SizedBox(height: 10),
                    _buildLocation(textStyleMedium),
                    SizedBox(height: 8),
                    _buildMetadata(textStyleMedium, formattedDate),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatedTitle(
      FontSizeController fontSizeController, int fontSizeBreakPoint) {
    return Expanded(
      child: FutureBuilder<String>(
        future: _translatedTitle,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                ),
              ),
            );
          }

          final displayText = snapshot.data ?? widget.d.name!;
          return Text(
            displayText,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize:
                  fontSizeController.fontSizeLarge.value > fontSizeBreakPoint
                      ? fontSizeController.fontSizeLarge.value
                      : fontSizeBreakPoint - 2,
              fontWeight:
                  fontSizeController.obtainContrastFromBase(FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: 'state_${widget.d.timestamp}',
      child: Container(
        height: 160,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
          child: CustomCacheImage(imageUrl: widget.d.imageUrl1),
        ),
      ),
    );
  }

  Widget _buildLocation(TextStyle textStyleMedium) {
    return Row(
      children: [
        Icon(Feather.map_pin, size: 16, color: Colors.grey),
        SizedBox(width: 3),
        Expanded(
          child: Text(
            widget.d.location!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyleMedium.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata(TextStyle textStyleMedium, String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.time, size: 16, color: Colors.grey[700]),
            SizedBox(width: 4),
            Text(
              formattedDate,
              style: textStyleMedium.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
        Row(
          children: [
            Icon(LineIcons.heart, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              widget.d.loves.toString(),
              style: textStyleMedium.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String date, BuildContext context) {
    final parts = date.split(" ");
    parts[1] = easy.tr(parts[1]);
    return parts.join(" ");
  }
}

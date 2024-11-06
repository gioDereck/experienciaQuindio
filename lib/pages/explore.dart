import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_hour/blocs/featured_bloc.dart';
import 'package:travel_hour/blocs/popular_places_bloc.dart';
import 'package:travel_hour/blocs/recent_places_bloc.dart';
import 'package:travel_hour/blocs/recommanded_places_bloc.dart';
import 'package:travel_hour/blocs/sp_state_one.dart';
import 'package:travel_hour/blocs/sp_state_two.dart';
import 'package:travel_hour/config/config.dart';
import 'package:travel_hour/services/navigation_service.dart';
import 'package:travel_hour/widgets/AvatarWithText.dart';
import 'package:travel_hour/widgets/featured_places_v2.dart';
import 'package:travel_hour/widgets/header.dart';
import 'package:travel_hour/widgets/popular_places.dart';
import 'package:travel_hour/widgets/recent_places.dart';
import 'package:travel_hour/widgets/recommended_places.dart';

class Explore extends StatefulWidget {
  Explore({Key? key}) : super(key: key);
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    reloadData();
  }

  Future reloadData() async {
    Future.delayed(Duration(milliseconds: 0)).then((_) async {
      await context
          .read<FeaturedBloc>()
          .getData()
          .then((value) => context.read<PopularPlacesBloc>().getData())
          .then((value) => context.read<RecentPlacesBloc>().getData())
          .then((value) => context.read<SpecialStateOneBloc>().getData())
          .then((value) => context.read<SpecialStateTwoBloc>().getData())
          .then((value) => context.read<RecommandedPlacesBloc>().getData());
    });
  }

  Future _onRefresh() async {
    context.read<FeaturedBloc>().onRefresh();
    context.read<PopularPlacesBloc>().onRefresh(mounted);
    context.read<RecentPlacesBloc>().onRefresh(mounted);
    context.read<SpecialStateOneBloc>().onRefresh();
    context.read<SpecialStateTwoBloc>().onRefresh();
    context.read<RecommandedPlacesBloc>().onRefresh(mounted);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _onRefresh(),
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 80,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white,
                                Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.00125),
                                Colors.white,
                              ],
                              stops: [0.0, 1.0, 0.1],
                            ),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                child: AvatarWithText(
                                  avatarUrl:
                                      '${Config().media_url}/uploads/2024/09/app/home/gloria_home.png',
                                  message: tr('search',
                                      namedArgs: {'name_ia': Config().nameIa}),
                                  iconPath: 'assets/images/icon_ia_v2.gif',
                                ),
                                onTap: () {
                                  NavigationService().navigateToIndex(7);
                                },
                              ),
                              //SearchButton(),
                              Featured(),
                            ],
                          ),
                        ),
                        PopularPlaces(),
                        RecentPlaces(),
                        RecommendedPlaces(),
                      ],
                    ),
                  ),
                ],
              ),

              // Header fijo en la parte superior
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: Header(withoutSearch: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

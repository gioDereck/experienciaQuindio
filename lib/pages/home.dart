import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hour/services/navigation_service.dart';
import 'package:travel_hour/utils/next_screen.dart';
// import 'package:travel_hour/pages/explore.dart';
// import 'package:travel_hour/pages/blogs.dart';
// import 'package:travel_hour/pages/bookmark.dart';
// import 'package:travel_hour/pages/ia_options.dart';
// import 'package:travel_hour/pages/profile.dart';
// import 'package:travel_hour/pages/states.dart';
// import 'package:travel_hour/pages/more_places.dart';
// import 'package:travel_hour/services/navigation_service.dart';
import 'package:travel_hour/widgets/contact_buttons.dart';

class HomePage extends StatefulWidget {
  final Widget child;
  HomePage({Key? key, required this.child})
      : super(key: key ?? NavigationService().homeKey);

  @override
  HomePageStatePublic createState() => HomePageStatePublic();
}

class HomePageStatePublic extends State<HomePage> {
  int _currentIndex = 0;

  // final List<Widget> _pages = [
  //   Explore(),
  //   StatesPage(),
  //   BlogPage(),
  //   BookmarkPage(),
  //   ProfilePage(),
  //   MorePlacesPage(
  //     title: 'popular',
  //     color: Colors.blueGrey[600],
  //   ),
  //   MorePlacesPage(
  //     title: 'recently added',
  //     color: Colors.blueGrey[600],
  //   ),
  //   IaOptionsPage()
  // ];

  final List<String> _routes = [
    '/explore',
    '/states',
    '/blogs',
    '/bookmarks',
    '/profile',
  ];

  List<IconData> iconList = [
    Feather.home,
    Feather.grid,
    Feather.list,
    Feather.bookmark,
    Feather.user,
  ];

  // void onTabTapped(int index) {
  //   if (_currentIndex != index) {
  //     setState(() => _currentIndex = index);

  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => _buildPageWithNav(index),
  //       ),
  //     );
  //   }
  // }

  void onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);

      // Si el índice es 5 o 6, navegar a la ruta 'place'
      if (index == 5 || index == 6) {
        // final title = index == 5 ? 'popular' : 'recently-added';
        nextScreenGoNamedWithOptions(context, 'places', pathParameters: {
          'place': index == 5 ? 'popular' : 'recently added'
        }, extra: {
          'title': index == 5 ? 'popular' : 'recently added',
          'color': Colors.blueGrey[600],
          'previous_route': 'explore'
        });
      } else {
        // nextScreenGoNamed(context, 'home');
        context.go(_routes[index]);
      }
    }
  }

  Widget _buildPageWithNav(int index) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          onTabTapped(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(elevation: 0, toolbarHeight: 0),
        bottomNavigationBar: Container(
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: Container(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(iconList.length, (i) {
                  return Container(
                    width: MediaQuery.of(context).size.width < 440 ? 60 : 88,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onTabTapped(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconList[i],
                              color: _currentIndex == i
                                  ? Colors.grey[800]
                                  : Colors.white,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ContactButtons(
          withoutAssistant: false,
          uniqueId: 'mainPage',
        ),
        // body: _pages[index],
        body: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPageWithNav(_currentIndex);
  }
}

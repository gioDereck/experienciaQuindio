import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final List<IconData> iconList = [
    Feather.home,
    Feather.grid,
    Feather.list,
    Feather.bookmark,
    Feather.user,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Container(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              iconList.length,
              (index) => Container(
                width: MediaQuery.of(context).size.width < 440 ? 60 : 88,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconList[index],
                          color: currentIndex == index
                              ? Colors.grey[800]
                              : Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
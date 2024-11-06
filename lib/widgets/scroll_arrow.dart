import 'package:flutter/material.dart'; // Para usar Material y otros widgets de Flutter
import 'package:travel_hour/utils/app_colors.dart';
// Para acceder a CustomColors

class ScrollArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLeft;

  const ScrollArrow({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: isLeft ? 16 : null,
      right: isLeft ? null : 16,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomColors.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: CircleBorder(),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

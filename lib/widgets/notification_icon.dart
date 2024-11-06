import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class NotificationIcon extends StatefulWidget {
  final bool hasNewNotification;
  final VoidCallback onPressed;

  NotificationIcon({required this.hasNewNotification, required this.onPressed});

  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Repetir la animación continuamente
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(8), // Aumenta el padding para ampliar el área de clic
          child: IconButton(
            icon: Icon(LineIcons.bell, size: 25),
            onPressed: widget.onPressed,
          ),
        ),
        if (widget.hasNewNotification)
          Positioned(
            right: 12, // Ajusta la posición según el nuevo padding
            top: 12,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + _controller.value * 0.3,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 10,
                  minHeight: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

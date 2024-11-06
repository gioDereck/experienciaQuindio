import 'package:flutter/material.dart';

class AvatarWithText extends StatefulWidget {
  final String avatarUrl;
  final String message;
  final String iconPath;

  const AvatarWithText({
    Key? key,
    required this.avatarUrl,
    required this.message,
    required this.iconPath,
  }) : super(key: key);

  @override
  State<AvatarWithText> createState() => _AvatarWithTextState();
}

class _AvatarWithTextState extends State<AvatarWithText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _displayedText = '';
  bool _isAnimating = true;

  @override
  void initState() {
    super.initState();
    
    // Configuramos el controlador de animación
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.message.length * 80),
      vsync: this,
    );

    // Creamos la animación
    _animation = Tween<double>(
      begin: 0,
      end: widget.message.length.toDouble(),
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _displayedText = widget.message.substring(0, _animation.value.toInt());
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isAnimating = false;
          });
        }
      });

    // Iniciamos la animación cuando el widget se construye
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      child: Stack(
        children: [
          Container(
            width: 350,
            height: 70,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.avatarUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 65, right: 10, top: 15, bottom: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  widget.iconPath,
                  width: 24,
                  height: 24,
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Text(
                        _isAnimating 
                          ? '$_displayedText...' 
                          : _displayedText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
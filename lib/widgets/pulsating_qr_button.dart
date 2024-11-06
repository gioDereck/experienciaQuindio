import 'package:flutter/material.dart';

class PulsingQRButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  
  const PulsingQRButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  _PulsingQRButtonState createState() => _PulsingQRButtonState();
}

class _PulsingQRButtonState extends State<PulsingQRButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Duración total del ciclo
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(5),
          child: widget.child,
        ),
      ),
    );
  }
}
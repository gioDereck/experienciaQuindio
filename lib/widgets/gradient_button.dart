import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final List<Color> gradientColors;

  const GradientButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25.0), // Más redondeado
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            // Texto en dos líneas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'available_in',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                ).tr(),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

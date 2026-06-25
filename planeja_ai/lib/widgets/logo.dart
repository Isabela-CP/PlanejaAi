import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double size;
  final bool showText;
  final MainAxisAlignment mainAxisAlignment;

  const Logo({
    super.key,
    this.size = 48.0,
    this.showText = true,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Retorno fallback para quando a imagem não for encontrada
            return Icon(Icons.image_not_supported,
                size: size, color: Colors.grey);
          },
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Planeja.AI',
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]
      ],
    );
  }
}

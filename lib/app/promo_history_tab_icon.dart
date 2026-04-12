import 'package:flutter/material.dart';

class PromoHistoryTabIcon extends StatelessWidget {
  const PromoHistoryTabIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: const [
        Icon(Icons.history, key: ValueKey<String>('nav.history.button')),
        Positioned(
          right: -2,
          top: -2,
          child: Icon(
            Icons.workspace_premium,
            key: ValueKey<String>('nav.history.pro.badge'),
            size: 12,
            color: Colors.amberAccent,
          ),
        ),
      ],
    );
  }
}

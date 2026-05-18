import 'package:flutter/material.dart';

class MaterialAllocationRow extends StatelessWidget {
  const MaterialAllocationRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.copies,
    required this.onRemove,
  });

  final String title;
  final String? subtitle;
  final int copies;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        if (subtitle != null) ...[const SizedBox(width: 8), Expanded(child: Text(subtitle!, overflow: TextOverflow.ellipsis))],
        const SizedBox(width: 8),
        Text('×$copies'),
        if (onRemove != null) IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline)),
      ],
    );
  }
}

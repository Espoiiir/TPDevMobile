import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  const InfoChip({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E8C9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0B458)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: theme.colorScheme.secondary),
            const SizedBox(width: 6),
          ],
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

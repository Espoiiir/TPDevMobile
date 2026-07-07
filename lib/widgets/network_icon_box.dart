import 'package:flutter/material.dart';

class NetworkIconBox extends StatelessWidget {
  const NetworkIconBox({
    required this.url,
    this.size = 72,
    this.borderRadius = 8,
    super.key,
  });

  final String url;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFF18202E),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported_outlined);
          },
        ),
      ),
    );
  }
}

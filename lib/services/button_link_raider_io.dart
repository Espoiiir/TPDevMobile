import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ButtonLinkRaiderIo {
  const ButtonLinkRaiderIo();

  Future<void> openExternalUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showError(context);
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d’ouvrir le lien Raider.IO.')),
    );
  }
}

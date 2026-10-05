import 'package:flutter/material.dart';

import '../hub_style.dart';

const _snackBarDuration = Duration(seconds: 2);

void showHubSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: HubStyle.body(color: HubStyle.white)),
        backgroundColor: HubStyle.navigationBar,
        duration: _snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: HubStyle.panelBorder, width: 2),
        ),
      ),
    );
}

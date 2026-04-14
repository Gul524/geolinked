import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolinked/utils/routes.dart';

final splashControllerProvider = Provider<SplashController>((ref) {
  return SplashController();
});

class SplashController {
  Future<void> initialize(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}

// Centralized utilities and common widgets ONLY.
// Avoid exporting screens or large third-party packages here to maintain Hot Reload speed.

// flutter
export 'package:flutter/material.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';

// configs
export '../configs/constants.dart';
export '../configs/providers/theme_provider.dart';
export '../configs/theme/app_theme.dart';

// utils
export 'routes.dart';
export 'app_messaging.dart';

// services
export '../services/local_storage_service.dart';

// shared widgets (Common across all features)
export '../shared/widgets/app_text_field.dart';
export '../shared/widgets/custom_button_widget.dart';
export '../shared/widgets/custom_chip_widget.dart';
export '../shared/widgets/custom_bottom_navigation_bar.dart';

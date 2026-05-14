// Centralized utilities and common widgets ONLY.
// Avoid exporting screens or large third-party packages here to maintain Hot Reload speed.

// flutter
export 'package:flutter/material.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';

// firebase (Essential base classes)
export 'package:firebase_core/firebase_core.dart';
export 'package:geolinked/firebase_options.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';

// packages 

// configs
export '../configs/constants.dart';
export '../configs/providers/theme_provider.dart';
export '../configs/theme/app_theme.dart';

// utils
export 'routes.dart';

// services
export '../services/local_storage_service.dart';
export '../services/api_service.dart';
export '../services/notification_service.dart';
export 'package:geolinked/services/geo_service.dart';

// shared widgets (Common across all features)
export '../shared/widgets/app_text_field.dart';
export '../shared/widgets/custom_button_widget.dart';
export '../shared/widgets/custom_chip_widget.dart';
export '../shared/widgets/custom_bottom_navigation_bar.dart';
export '../shared/widgets/app_messaging.dart';
export '../feature/auth/widgets/auth_shell_widget.dart';
export '../shared/widgets/custom_dropdown.dart';

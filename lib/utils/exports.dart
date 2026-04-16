// flutter
export 'package:flutter/material.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';

// configs
export '../configs/providers/theme_provider.dart';
export '../configs/theme/app_theme.dart';

// routes
export 'routes.dart';

// services
export '../services/api_service.dart';
export '../services/geo_service.dart';
export '../services/local_storage_service.dart';
export '../services/notification_service.dart';

// shared widgets
export '../shared/widgets/app_messaging.dart';
export '../shared/widgets/app_text_field.dart';
export '../shared/widgets/custom_button_widget.dart';
export '../shared/widgets/custom_chip_widget.dart';
export '../shared/widgets/custom_bottom_navigation_bar.dart';
export '../shared/widgets/custom_dropdown.dart';
export '../shared/widgets/custom_search_field.dart';

// auth
export '../feature/auth/login/login_controller.dart';
export '../feature/auth/login/login_screen.dart';
export '../feature/auth/signup/otp_verification_controller.dart';
export '../feature/auth/signup/otp_verification_screen.dart';
export '../feature/auth/signup/signup_controller.dart';
export '../feature/auth/signup/signup_screen.dart';
export '../feature/auth/widgets/auth_header_widget.dart';
export '../feature/auth/widgets/auth_switch_prompt_widget.dart';
export '../feature/auth/widgets/auth_shell_widget.dart';

// splash
export '../feature/splash/splash_controller.dart';
export '../feature/splash/splash_screen.dart';
export '../feature/splash/widgets/splash_brand_animation_widget.dart';

// onboarding
export '../feature/onboarding/onboarding_controller.dart';
export '../feature/onboarding/onboarding_screen.dart';
export '../feature/onboarding/widgets/onboarding_hero_card_widget.dart';
export '../feature/onboarding/widgets/onboarding_page_indicator_widget.dart';

// home
export '../feature/home/home_controller.dart';
export '../feature/home/home_screen.dart';

// ask
export '../feature/ask/ask_controller.dart';
export '../feature/ask/ask_discussion_controller.dart';
export '../feature/ask/ask_discussion_screen.dart';
export '../feature/ask/ask_sheet/ask_sheet.dart';
export '../feature/ask/ask_sheet/ask_sheet_controller.dart';
export '../feature/ask/ask_screen.dart';
export '../feature/ask/widgets/ask_history_header_widget.dart';
export '../feature/ask/widgets/ask_history_item_widget.dart';
export '../feature/ask/widgets/ask_message_bubble_widget.dart';
export '../feature/ask/widgets/ask_question_card_widget.dart';
export '../feature/ask/widgets/ask_reply_input_widget.dart';
export '../feature/ask/widgets/ask_resolve_banner_widget.dart';
export '../feature/ask/widgets/ask_thread_header_widget.dart';

// broadcast
export '../feature/broadcast/broadcast_controller.dart';
export '../feature/broadcast/broadcast_discussion_controller.dart';
export '../feature/broadcast/broadcast_discussion_screen.dart';
export '../feature/broadcast/broadcast_sheet/broadcast_sheet.dart';
export '../feature/broadcast/broadcast_sheet/broadcast_sheet_controller.dart';
export '../feature/broadcast/broadcast_screen.dart';
export '../feature/broadcast/widgets/broadcast_discussion_message_bubble_widget.dart';
export '../feature/broadcast/widgets/broadcast_header_widget.dart';
export '../feature/broadcast/widgets/broadcast_list_item_widget.dart';

// profile
export '../feature/profile/profile_controller.dart';
export '../feature/profile/profile_screen.dart';
export '../feature/profile/widgets/helpfulness_score_card_widget.dart';
export '../feature/profile/widgets/profile_header_widget.dart';
export '../feature/profile/widgets/profile_section_card_widget.dart';
export '../feature/profile/widgets/profile_setting_rows_widget.dart';

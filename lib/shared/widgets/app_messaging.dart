import 'dart:async';

import 'package:geolinked/utils/app_exports.dart';

enum AppMessageType { error, success, warning, info }

class AppMessaging {
  static OverlayEntry? _activeEntry;

  static void showError(BuildContext context, String message) {
    _show(context, message, AppMessageType.error);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppMessageType.success);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppMessageType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppMessageType.info);
  }

  static void _show(BuildContext context, String message, AppMessageType type) {
    final OverlayState? overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return;
    }

    _activeEntry?.remove();
    _activeEntry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return _TopMessageBanner(
          message: message,
          type: type,
          onDismissed: () {
            if (_activeEntry == entry) {
              _activeEntry?.remove();
              _activeEntry = null;
            }
          },
        );
      },
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _TopMessageBanner extends StatefulWidget {
  const _TopMessageBanner({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  final String message;
  final AppMessageType type;
  final VoidCallback onDismissed;

  @override
  State<_TopMessageBanner> createState() => _TopMessageBannerState();
}

class _TopMessageBannerState extends State<_TopMessageBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () async {
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = switch (widget.type) {
      AppMessageType.error => const Color(0xFFDC2626),
      AppMessageType.success => const Color(0xFF16A34A),
      AppMessageType.warning => const Color(0xFFF59E0B),
      AppMessageType.info => Theme.of(context).colorScheme.primary,
    };

    final IconData icon = switch (widget.type) {
      AppMessageType.error => Icons.error_outline,
      AppMessageType.success => Icons.check_circle_outline,
      AppMessageType.warning => Icons.warning_amber_rounded,
      AppMessageType.info => Icons.info_outline,
    };

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _offset,
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

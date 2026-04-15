import 'dart:ui';

import 'package:geolinked/utils/app_exports.dart';

class CustomBottomNavigationItem {
  const CustomBottomNavigationItem({
    required this.icon,
    required this.label,
    this.activeColor,
    this.inactiveColor,
  });

  final IconData icon;
  final String label;
  final Color? activeColor;
  final Color? inactiveColor;
}

class BottomNavRoundIcon extends StatelessWidget {
  const BottomNavRoundIcon({
    required this.icon,
    required this.selected,
    required this.primary,
    required this.activeColor,
    required this.inactiveColor,
    super.key,
  });

  final IconData icon;
  final bool selected;
  final Color primary;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 30,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: selected ? primary.withValues(alpha: 0.14) : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: 15,
        color: selected ? activeColor : inactiveColor,
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<CustomBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final divider = onSurface.withValues(alpha: 0.12);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.88),
            border: Border(top: BorderSide(color: divider)),
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: SizedBox(
              height: 56,
              child: Row(
                children: List<Widget>.generate(items.length, (int index) {
                  final item = items[index];
                  final selected = index == currentIndex;
                  final iconActiveColor = item.activeColor ?? primary;
                  final iconInactiveColor =
                      item.inactiveColor ?? onSurface.withValues(alpha: 0.62);

                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onTap(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 3,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            BottomNavRoundIcon(
                              icon: item.icon,
                              selected: selected,
                              primary: primary,
                              activeColor: iconActiveColor,
                              inactiveColor: iconInactiveColor,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: selected
                                        ? iconActiveColor
                                        : onSurface.withValues(alpha: 0.62),
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

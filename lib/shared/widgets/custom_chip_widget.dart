import 'package:geolinked/utils/app_exports.dart';

enum CustomChipType { success, info, warning, alert }

class CustomChipWidget extends StatelessWidget {
  const CustomChipWidget({
    required this.text,
    required this.iconData,
    this.color,
    this.type = CustomChipType.info,
    this.onTap,
    super.key,
  });

  final String text;
  final IconData iconData;
  final Color? color;
  final CustomChipType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = color ?? _typeColor(type);
    final Color background = foreground.withValues(alpha: 0.14);

    final Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: foreground.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(iconData, size: 13, color: foreground),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: chip,
      ),
    );
  }

  Color _typeColor(CustomChipType chipType) {
    switch (chipType) {
      case CustomChipType.success:
        return const Color(0xFF1B8E3E);
      case CustomChipType.info:
        return const Color(0xFF0D47A1);
      case CustomChipType.warning:
        return const Color(0xFFB86500);
      case CustomChipType.alert:
        return const Color(0xFFC62828);
    }
  }
}

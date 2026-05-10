import 'package:geolinked/utils/app_exports.dart';

class AskHistoryHeaderWidget extends StatelessWidget {
  const AskHistoryHeaderWidget({
    required this.subtitle,
    this.onCreatePressed,
    this.onBackTap,
    super.key,
  });

  final String subtitle;
  final VoidCallback? onCreatePressed;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (onBackTap != null) ...[
                IconButton(
                  onPressed: onBackTap,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  'Ask History',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (onCreatePressed != null)
                IconButton(
                  onPressed: onCreatePressed,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: EdgeInsets.only(left: onBackTap != null ? 32 : 0),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.58),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

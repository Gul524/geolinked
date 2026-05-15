import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/datetime_helper.dart';

class AskHistoryItemWidget extends StatelessWidget {
  const AskHistoryItemWidget({
    required this.item,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final AskModel item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final bool resolved = item.status == AskStatus.resolved;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.help_outline_rounded, color: primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                         DateFormat.getDateOrTime(item.createdAt),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: onSurface.withValues(alpha: 0.45),
                            ),
                      ),
                      if (onDelete != null)
                        PopupMenuButton<int>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: onSurface.withValues(alpha: 0.4),
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (val) {
                            if (val == 0) onDelete!();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 0,
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.74),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: <Widget>[
                            _Pill(label: '💬 ${item.replyCount}'),
                            if (item.latitude != null)
                              _Pill(label: '📍 Nearby'),
                            _Pill(label: resolved ? '✅ resolved' : '🟢 active'),
                          ],
                        ),
                      ),
                      if (item.imageUrl != null)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.62),
        ),
      ),
    );
  }
}

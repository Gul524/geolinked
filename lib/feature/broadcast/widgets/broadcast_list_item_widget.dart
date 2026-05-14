import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/shared/widgets/full_screen_viewer.dart';

class BroadcastListItemWidget extends StatelessWidget {
  const BroadcastListItemWidget({
    required this.item,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final BroadcastModel item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    
    // Severity Color logic
    final Color severityColor = switch (item.severity) {
      BroadcastSeverity.info => Colors.blue,
      BroadcastSeverity.medium => Colors.orange,
      BroadcastSeverity.high => Colors.red,
      BroadcastSeverity.critical => Colors.purple,
    };

    final String emoji = switch (item.severity) {
      BroadcastSeverity.info => 'ℹ️',
      BroadcastSeverity.medium => '⚠️',
      BroadcastSeverity.high => '🚨',
      BroadcastSeverity.critical => '🛑',
    };

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
                color: severityColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.category,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: severityColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                        ),
                      ),
                      Text(
                        'Just now',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: onSurface.withOpacity(0.42),
                            ),
                      ),
                      if (onDelete != null)
                        PopupMenuButton<int>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: onSurface.withOpacity(0.4),
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
                    item.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.28),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: <Widget>[
                            _MetaPill(label: '👁️ ${item.seenCount}'),
                            if (item.latitude != null)
                              _MetaPill(label: '📍 Nearby'),
                            _MetaPill(label: '✅ ${item.verifiedCount}'),
                          ],
                        ),
                      ),
                      if (item.imageUrl != null)
                        GestureDetector(
                          onTap: () => FullScreenImageViewer.show(
                            context,
                            item.imageUrl!,
                            heroTag: 'broadcast_${item.id}',
                          ),
                          child: Hero(
                            tag: 'broadcast_${item.id}',
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: severityColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(item.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

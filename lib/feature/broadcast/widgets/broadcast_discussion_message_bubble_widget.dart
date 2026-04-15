import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_discussion_controller.dart';

class BroadcastDiscussionMessageBubbleWidget extends StatelessWidget {
  const BroadcastDiscussionMessageBubbleWidget({
    required this.message,
    super.key,
  });

  final BroadcastDiscussionMessage message;

  @override
  Widget build(BuildContext context) {
    final bool self = message.isCurrentUser;
    final Color primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(self ? 72 : 10, 8, self ? 10 : 72, 8),
      child: Column(
        crossAxisAlignment: self
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: self
                  ? LinearGradient(
                      colors: <Color>[primary, const Color(0xFF0B4AA9)],
                    )
                  : null,
              color: self
                  ? null
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.06),
            ),
            child: Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: self ? Colors.white : null,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            self
                ? '${message.timeAgo}   ${message.author}'
                : '${message.author} (${message.distanceText})  ${message.timeAgo}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

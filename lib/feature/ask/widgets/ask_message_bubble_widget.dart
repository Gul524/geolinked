import 'package:flutter/material.dart';
import 'package:geolinked/feature/ask/ask_discussion_controller.dart';

class AskMessageBubbleWidget extends StatelessWidget {
  const AskMessageBubbleWidget({required this.message, super.key});

  final AskDiscussionMessage message;

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
                      colors: <Color>[
                        primary.withValues(alpha: 0.96),
                        const Color(0xFF0B4AA9),
                      ],
                    )
                  : null,
              color: self
                  ? null
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.06),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: self ? 0.12 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: self ? Colors.white : null,
                height: 1.35,
              ),
            ),
          ),
          if (!self) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              '${message.author} (${message.distanceText})  ${message.timeAgo}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.45),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: <Widget>[
                _VoteChip(label: '✓ Correct', color: const Color(0xFF16A34A)),
                _VoteChip(label: '✗ Incorrect', color: const Color(0xFFEF4444)),
              ],
            ),
          ],
          if (self)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${message.timeAgo}   ${message.author}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VoteChip extends StatelessWidget {
  const _VoteChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

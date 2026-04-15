import 'package:flutter/material.dart';

class AskResolveBannerWidget extends StatelessWidget {
  const AskResolveBannerWidget({
    required this.resolved,
    required this.onPressed,
    super.key,
  });

  final bool resolved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color green = const Color(0xFF16A34A);

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: green.withValues(alpha: 0.35)),
      ),
      child: ListTile(
        onTap: onPressed,
        leading: Text(
          resolved ? '✅' : '☑️',
          style: const TextStyle(fontSize: 22),
        ),
        title: Text(
          resolved ? 'Marked as Resolved' : 'Mark as Resolved',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: green,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '2 people helped answer your question',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.58),
          ),
        ),
      ),
    );
  }
}

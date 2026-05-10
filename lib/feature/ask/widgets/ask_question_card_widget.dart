import 'package:flutter/material.dart';
import 'package:geolinked/model/models.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/shared/widgets/full_screen_viewer.dart';

class AskQuestionCardWidget extends StatelessWidget {
  const AskQuestionCardWidget({required this.item, super.key});

  final AskModel item;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[primary, const Color(0xFF0B4AA9)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primary.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (item.imageUrl != null)
              GestureDetector(
                onTap: () => FullScreenImageViewer.show(
                  context,
                  item.imageUrl!,
                  heroTag: 'ask_${item.id}',
                ),
                child: Hero(
                  tag: 'ask_${item.id}',
                  child: Image.network(
                    item.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR QUESTION',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withOpacity(0.78),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.36),
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

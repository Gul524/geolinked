import 'package:geolinked/utils/app_exports.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    required this.name,
    required this.handle,
    required this.city,
    super.key,
  });

  final String name;
  final String handle;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Theme.of(context).colorScheme.primary,
            const Color(0xFF1F7BD4),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 36,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$handle • $city',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

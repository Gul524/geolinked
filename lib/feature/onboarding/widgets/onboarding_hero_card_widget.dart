import 'package:geolinked/utils/app_exports.dart';

class OnboardingHeroCardWidget extends StatelessWidget {
  const OnboardingHeroCardWidget({required this.pageIndex, super.key});

  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color surface = Theme.of(context).colorScheme.surface;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    final List<Color> palette = <Color>[
      const Color(0xFF2F80ED),
      const Color(0xFF00B8A9),
      const Color(0xFFFF8A00),
      const Color(0xFFFF3B30),
    ];

    final bool secondPage = pageIndex == 1;

    return Container(
      width: double.infinity,
      height: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: surface,
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 18,
              height: 10,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: onSurface.withValues(alpha: 0.03),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 110,
                      top: secondPage ? 130 : 120,
                      child: _ActionChip(
                        icon: Icons.forum_outlined,
                        color: palette[2],
                      ),
                    ),
                    Positioned(
                      left: 172,
                      top: secondPage ? 110 : 100,
                      child: _ActionChip(
                        icon: Icons.shopping_bag_outlined,
                        color: palette[3],
                      ),
                    ),
                    Positioned(
                      left: secondPage ? 72 : 66,
                      top: secondPage ? 208 : 238,
                      child: _ActionChip(
                        icon: Icons.thumb_up_off_alt,
                        color: palette[0],
                      ),
                    ),
                    Positioned(
                      right: 22,
                      top: secondPage ? 200 : 222,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: onSurface.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          child: Text(
                            secondPage ? 'Asking near you ✨' : 'Road closed 🤝',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: onSurface.withValues(alpha: 0.52),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      left: 24,
                      child: Container(
                        width: 82,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              primary.withValues(alpha: 0.95),
                              primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}

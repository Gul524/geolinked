import 'package:geolinked/utils/app_exports.dart';

class AuthShellWidget extends StatelessWidget {
  const AuthShellWidget({
    required this.title,
    required this.child,
    this.appName = 'GeoLinked',
    this.footer,
    super.key,
  });

  final String appName;
  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;
    final Color background = Theme.of(
      context,
    ).colorScheme.surfaceContainerLowest;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                child: Column(
                  children: <Widget>[
                    Spacer(flex: 2),
                    Center(
                      child: Text(
                        appName,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: onSurface,
                                  height: 1.15,
                                ),
                          ),
                          const SizedBox(height: 20),
                          child,
                        ],
                      ),
                    ),
                    if (footer != null) ...<Widget>[
                      const SizedBox(height: 18),
                      footer!,
                    ],
                    Spacer(flex: 3),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:geolinked/utils/app_exports.dart';

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget({
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.height = 50,
    this.borderRadius = 14,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return _PrimaryGradientButton(
        label: label,
        onPressed: onPressed,
        height: height,
        borderRadius: borderRadius,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PrimaryGradientButton extends StatelessWidget {
  const _PrimaryGradientButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final bool enabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[primary.withValues(alpha: 0.9), primary],
                )
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                    Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ],
                ),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

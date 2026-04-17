import 'package:geolinked/utils/app_exports.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChange,
    required this.itemBuilder,
    this.hintText,
    this.isEditable = true,
    this.validator,
    super.key,
  });

  final String label;
  final String? hintText;
  final List<T> options;
  final T? selected;
  final ValueChanged<T?> onChange;
  final String Function(T item) itemBuilder;
  final bool isEditable;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: selected,
          validator: validator,
          items: options
              .map(
                (T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemBuilder(item),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
              .toList(),
          onChanged: isEditable ? onChange : null,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.2,
              ),
            ),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}

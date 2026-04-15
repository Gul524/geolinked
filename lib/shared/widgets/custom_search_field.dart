import 'package:geolinked/utils/app_exports.dart';

class CustomSearchField extends StatefulWidget {
  const CustomSearchField({
    required this.controller,
    this.label = 'Search',
    this.hintText = 'Search here...',
    this.isEditable = true,
    this.showClearButton = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isEditable;
  final bool showClearButton;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CustomSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      isEditable: widget.isEditable,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(
        Icons.search_rounded,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      ),
      suffixIcon: _buildSuffixIcon(),
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }

  Widget? _buildSuffixIcon() {
    if (!widget.showClearButton || widget.controller.text.isEmpty) {
      return null;
    }

    return IconButton(
      onPressed: widget.isEditable
          ? () {
              widget.controller.clear();
              widget.onChanged?.call('');
            }
          : null,
      icon: const Icon(Icons.close_rounded, size: 18),
    );
  }
}

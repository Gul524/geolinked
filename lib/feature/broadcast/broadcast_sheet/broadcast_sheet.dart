import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet_controller.dart';

class BroadcastSheet extends ConsumerStatefulWidget {
  const BroadcastSheet({
    this.initialTargetLocation,
    this.onSelectTargetLocation,
    super.key,
  });

  final BroadcastSheetGeoPoint? initialTargetLocation;
  final Future<BroadcastSheetGeoPoint?> Function()? onSelectTargetLocation;

  static Future<BroadcastSheetResult?> showSheet(
    BuildContext context, {
    BroadcastSheetGeoPoint? targetLocation,
    Future<BroadcastSheetGeoPoint?> Function()? onSelectTargetLocation,
  }) {
    return showModalBottomSheet<BroadcastSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BroadcastSheet(
        initialTargetLocation: targetLocation,
        onSelectTargetLocation: onSelectTargetLocation,
      ),
    );
  }

  @override
  ConsumerState<BroadcastSheet> createState() => _BroadcastSheetState();
}

class _BroadcastSheetState extends ConsumerState<BroadcastSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(broadcastSheetControllerProvider.notifier)
          .initialize(initialTargetLocation: widget.initialTargetLocation);
    });
  }

  Future<void> _onSelectTargetLocation() async {
    final BroadcastSheetController controller = ref.read(
      broadcastSheetControllerProvider.notifier,
    );

    final BroadcastSheetGeoPoint selected =
        await widget.onSelectTargetLocation?.call() ??
        const BroadcastSheetGeoPoint(latitude: 24.8607, longitude: 67.0011);

    controller.setTargetLocation(selected);
  }

  @override
  Widget build(BuildContext context) {
    final BroadcastSheetState state = ref.watch(
      broadcastSheetControllerProvider,
    );
    final BroadcastSheetController controller = ref.read(
      broadcastSheetControllerProvider.notifier,
    );

    final Color surface = Theme.of(context).colorScheme.surface;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: onSurface.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create Broadcast',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Notify nearby people with timely local updates.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      CustomChipWidget(
                        text: '${state.radiusMeters}m radius',
                        iconData: Icons.radar_rounded,
                        type: CustomChipType.info,
                      ),
                      CustomChipWidget(
                        text: 'Select target location',
                        iconData: Icons.place_rounded,
                        type: CustomChipType.alert,
                        onTap: _onSelectTargetLocation,
                      ),
                      if (state.targetLocation != null)
                        CustomChipWidget(
                          text: state.targetLocation!.compactLabel,
                          iconData: Icons.my_location_rounded,
                          type: CustomChipType.success,
                          onTap: controller.clearTargetLocation,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'People radius in meters (${state.radiusMeters})',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: state.radiusMeters.toDouble(),
                    min: BroadcastSheetController.minRadiusMeters.toDouble(),
                    max: BroadcastSheetController.maxRadiusMeters.toDouble(),
                    divisions:
                        (BroadcastSheetController.maxRadiusMeters -
                            BroadcastSheetController.minRadiusMeters) ~/
                        50,
                    label: '${state.radiusMeters}m',
                    onChanged: controller.setRadius,
                  ),
                  const SizedBox(height: 8),
                  CustomDropdown<String>(
                    label: 'Category',
                    hintText: 'Select a broadcast category',
                    options: state.categories,
                    selected: state.selectedCategory,
                    onChange: controller.setCategory,
                    itemBuilder: (String item) => item,
                    validator: controller.validateCategory,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Broadcast message',
                    hintText: 'Write the update people should see.',
                    controller: controller.questionController,
                    maxLines: 4,
                    validator: controller.validateQuestion,
                  ),
                  const SizedBox(height: 16),
                  CustomButtonWidget(
                    label: 'Post Broadcast',
                    onPressed: () {
                      final BroadcastSheetResult? result = controller
                          .createResult();
                      if (result == null) {
                        AppMessaging.showWarning(
                          context,
                          'Please fill all required fields correctly.',
                        );
                        return;
                      }

                      Navigator.of(context).pop(result);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet_controller.dart';

class BroadcastSheet extends ConsumerStatefulWidget {
  const BroadcastSheet({
    this.initialTargetLocation,
    this.initialTargetLocationName,
    this.onSelectTargetLocation,
    super.key,
  });

  final BroadcastSheetGeoPoint? initialTargetLocation;
  final String? initialTargetLocationName;
  final Future<BroadcastSheetGeoPoint?> Function()? onSelectTargetLocation;

  static Future<BroadcastSheetResult?> showSheet(
    BuildContext context, {
    BroadcastSheetGeoPoint? targetLocation,
    String? targetLocationName,
    Future<BroadcastSheetGeoPoint?> Function()? onSelectTargetLocation,
  }) {
    return showModalBottomSheet<BroadcastSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BroadcastSheet(
        initialTargetLocation: targetLocation,
        initialTargetLocationName: targetLocationName,
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
      ref.read(broadcastSheetControllerProvider.notifier).initialize(
            initialTargetLocation: widget.initialTargetLocation,
            initialLocationName: widget.initialTargetLocationName,
          );
    });
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
              color: Colors.black.withOpacity(0.12),
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
                        color: onSurface.withOpacity(0.15),
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
                          color: onSurface.withOpacity(0.65),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      if (state.targetLocation != null)
                        CustomChipWidget(
                          text: state.targetLocation!.compactLabel,
                          iconData: Icons.my_location_rounded,
                          type: CustomChipType.success,
                          onTap: controller.clearTargetLocation,
                        ),
                      if (state.locationName != null)
                        SizedBox(
                          width: 200,
                          child: CustomChipWidget(
                            text: state.locationName!,
                            iconData: Icons.location_on_rounded,
                            type: CustomChipType.success,
                            onTap: controller.clearTargetLocation,
                          ),
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
                    divisions: (BroadcastSheetController.maxRadiusMeters -
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
                  _ImagePickerWidget(
                    image: state.image,
                    onPick: () => _showImageSourceOptions(context, controller),
                    onRemove: controller.removeImage,
                  ),
                  const SizedBox(height: 20),
                  CustomButtonWidget(
                    label: state.isUploading ? 'Uploading Image...' : 'Post Broadcast',
                    isLoading: state.isUploading,
                    onPressed: () async {
                      final BroadcastSheetResult? result =
                          await controller.createResult();
                      if (result == null && !state.isUploading) {
                        AppMessaging.showWarning(
                          context,
                          'Please fill all required fields correctly.',
                        );
                        return;
                      }

                      if (result != null && context.mounted) {
                        Navigator.of(context).pop(result);
                      }
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

  void _showImageSourceOptions(
    BuildContext context,
    BroadcastSheetController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerWidget extends StatelessWidget {
  const _ImagePickerWidget({
    required this.image,
    required this.onPick,
    required this.onRemove,
  });

  final File? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color surface = Theme.of(context).colorScheme.surfaceVariant;

    if (image != null) {
      return Stack(
        children: <Widget>[
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: DecorationImage(
                image: FileImage(image!),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add_a_photo_rounded, color: primary),
            const SizedBox(height: 4),
            Text(
              'Add Image (Optional)',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

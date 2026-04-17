import 'package:geolinked/utils/app_exports.dart';

class BroadcastSheetGeoPoint {
  const BroadcastSheetGeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  String get compactLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

class BroadcastSheetResult {
  const BroadcastSheetResult({
    required this.radiusMeters,
    required this.category,
    required this.question,
    this.targetLocation,
  });

  final int radiusMeters;
  final String category;
  final String question;
  final BroadcastSheetGeoPoint? targetLocation;
}

class BroadcastSheetState {
  const BroadcastSheetState({
    required this.radiusMeters,
    required this.categories,
    this.selectedCategory,
    this.targetLocation,
    this.locationName,
  });

  final int radiusMeters;
  final List<String> categories;
  final String? selectedCategory;
  final BroadcastSheetGeoPoint? targetLocation;
  final String? locationName;

  BroadcastSheetState copyWith({
    int? radiusMeters,
    List<String>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    BroadcastSheetGeoPoint? targetLocation,
    bool clearTargetLocation = false,
    String? locationName,
    bool clearLocationName = false,
  }) {
    return BroadcastSheetState(
      radiusMeters: radiusMeters ?? this.radiusMeters,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      targetLocation: clearTargetLocation
          ? null
          : (targetLocation ?? this.targetLocation),
      locationName: clearLocationName
          ? null
          : (locationName ?? this.locationName),
    );
  }
}

class BroadcastSheetController extends Notifier<BroadcastSheetState> {
  static const int minRadiusMeters = 100;
  static const int maxRadiusMeters = 1000;
  static const int defaultRadiusMeters = 300;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController questionController = TextEditingController();

  @override
  BroadcastSheetState build() {
    ref.onDispose(questionController.dispose);

    return const BroadcastSheetState(
      radiusMeters: defaultRadiusMeters,
      categories: <String>[
        'Traffic',
        'Road Block',
        'Safety Alert',
        'Utility Issue',
        'Public Event',
        'Market Update',
      ],
    );
  }

  void initialize({
    BroadcastSheetGeoPoint? initialTargetLocation,
    String? initialLocationName,
  }) {
    questionController.clear();
    state = state.copyWith(
      radiusMeters: defaultRadiusMeters,
      clearSelectedCategory: true,
      targetLocation: initialTargetLocation,
      locationName: initialLocationName,
    );
  }

  void setRadius(double value) {
    final int normalized = value.round().clamp(
      minRadiusMeters,
      maxRadiusMeters,
    );
    state = state.copyWith(radiusMeters: normalized);
  }

  void setCategory(String? value) {
    state = state.copyWith(selectedCategory: value);
  }

  void setTargetLocation(BroadcastSheetGeoPoint targetLocation) {
    state = state.copyWith(
      targetLocation: targetLocation,
      clearLocationName: true,
    );
  }

  void clearTargetLocation() {
    state = state.copyWith(clearTargetLocation: true, clearLocationName: true);
  }

  String? validateCategory(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Select a category';
    }
    return null;
  }

  String? validateQuestion(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'Broadcast message is required';
    }

    if (input.length < 8) {
      return 'Please add more detail';
    }

    return null;
  }

  BroadcastSheetResult? createResult() {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    return BroadcastSheetResult(
      radiusMeters: state.radiusMeters,
      category: state.selectedCategory!.trim(),
      question: questionController.text.trim(),
      targetLocation: state.targetLocation,
    );
  }
}

final broadcastSheetControllerProvider =
    NotifierProvider<BroadcastSheetController, BroadcastSheetState>(
      BroadcastSheetController.new,
    );

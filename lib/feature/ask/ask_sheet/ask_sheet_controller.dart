import 'package:geolinked/utils/app_exports.dart';

class AskSheetGeoPoint {
  const AskSheetGeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  String get compactLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

class AskSheetResult {
  const AskSheetResult({
    required this.radiusMeters,
    required this.subject,
    required this.question,
    this.targetLocation,
  });

  final int radiusMeters;
  final String subject;
  final String question;
  final AskSheetGeoPoint? targetLocation;
}

class AskSheetState {
  const AskSheetState({
    required this.radiusMeters,
    this.targetLocation,
    this.locationName,
  });

  final int radiusMeters;
  final AskSheetGeoPoint? targetLocation;
  final String? locationName;

  AskSheetState copyWith({
    int? radiusMeters,
    AskSheetGeoPoint? targetLocation,
    bool clearTargetLocation = false,
    String? locationName,
    bool clearLocationName = false,
  }) {
    return AskSheetState(
      radiusMeters: radiusMeters ?? this.radiusMeters,
      targetLocation: clearTargetLocation
          ? null
          : (targetLocation ?? this.targetLocation),
      locationName: clearLocationName
          ? null
          : (locationName ?? this.locationName),
    );
  }
}

class AskSheetController extends Notifier<AskSheetState> {
  static const int minRadiusMeters = 100;
  static const int maxRadiusMeters = 1000;
  static const int defaultRadiusMeters = 300;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  @override
  AskSheetState build() {
    ref.onDispose(() {
      subjectController.dispose();
      questionController.dispose();
    });

    return const AskSheetState(radiusMeters: defaultRadiusMeters);
  }

  void initialize({
    AskSheetGeoPoint? initialTargetLocation,
    String? initialLocationName,
  }) {
    subjectController.clear();
    questionController.clear();

    state = AskSheetState(
      radiusMeters: defaultRadiusMeters,
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

  String? validateSubject(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'Subject is required';
    }

    if (input.length < 4) {
      return 'Subject is too short';
    }

    return null;
  }

  String? validateQuestion(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return 'Question is required';
    }

    if (input.length < 8) {
      return 'Please add more detail';
    }

    return null;
  }

  AskSheetResult? createResult() {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    return AskSheetResult(
      radiusMeters: state.radiusMeters,
      subject: subjectController.text.trim(),
      question: questionController.text.trim(),
      targetLocation: state.targetLocation,
    );
  }
}

final askSheetControllerProvider =
    NotifierProvider<AskSheetController, AskSheetState>(AskSheetController.new);

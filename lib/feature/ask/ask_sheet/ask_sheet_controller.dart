import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/services/storage_service.dart';

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
    this.imageUrl,
  });

  final int radiusMeters;
  final String subject;
  final String question;
  final AskSheetGeoPoint? targetLocation;
  final String? imageUrl;
}

class AskSheetState {
  const AskSheetState({
    required this.radiusMeters,
    this.targetLocation,
    this.locationName,
    this.image,
    this.isUploading = false,
  });

  final int radiusMeters;
  final AskSheetGeoPoint? targetLocation;
  final String? locationName;
  final File? image;
  final bool isUploading;

  AskSheetState copyWith({
    int? radiusMeters,
    AskSheetGeoPoint? targetLocation,
    bool clearTargetLocation = false,
    String? locationName,
    bool clearLocationName = false,
    File? image,
    bool clearImage = false,
    bool? isUploading,
  }) {
    return AskSheetState(
      radiusMeters: radiusMeters ?? this.radiusMeters,
      targetLocation: clearTargetLocation
          ? null
          : (targetLocation ?? this.targetLocation),
      locationName: clearLocationName
          ? null
          : (locationName ?? this.locationName),
      image: clearImage ? null : (image ?? this.image),
      isUploading: isUploading ?? this.isUploading,
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
  final ImagePicker _picker = ImagePicker();

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

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        state = state.copyWith(image: File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void removeImage() {
    state = state.copyWith(clearImage: true);
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

  Future<AskSheetResult?> createResult() async {
    if (!formKey.currentState!.validate()) {
      return null;
    }

    String? imageUrl;
    if (state.image != null) {
      state = state.copyWith(isUploading: true);
      final storage = StorageService.instance;
      imageUrl = await storage.uploadPostImage(state.image!, 'asks');
      state = state.copyWith(isUploading: false);
    }

    return AskSheetResult(
      radiusMeters: state.radiusMeters,
      subject: subjectController.text.trim(),
      question: questionController.text.trim(),
      targetLocation: state.targetLocation,
      imageUrl: imageUrl,
    );
  }
}

final askSheetControllerProvider =
    NotifierProvider<AskSheetController, AskSheetState>(AskSheetController.new);

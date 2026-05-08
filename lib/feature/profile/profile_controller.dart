import 'package:geolinked/utils/app_exports.dart';

class ProfileState {
  const ProfileState({
    required this.userName,
    required this.handle,
    required this.city,
    required this.helpfulnessScore,
    required this.helpfulVotesThisMonth,
    required this.askRadiusMeters,
    required this.broadcastRadiusKm,
    required this.pushNotificationsEnabled,
    required this.anonymousModeEnabled,
    required this.quietHours,
    required this.emergencyContactCount,
  });

  final String userName;
  final String handle;
  final String city;

  final int helpfulnessScore;
  final int helpfulVotesThisMonth;

  final double askRadiusMeters;
  final double broadcastRadiusKm;

  final bool pushNotificationsEnabled;
  final bool anonymousModeEnabled;

  final String quietHours;
  final int emergencyContactCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userName': userName,
      'handle': handle,
      'city': city,
      'helpfulnessScore': helpfulnessScore,
      'helpfulVotesThisMonth': helpfulVotesThisMonth,
      'askRadiusMeters': askRadiusMeters,
      'broadcastRadiusKm': broadcastRadiusKm,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'anonymousModeEnabled': anonymousModeEnabled,
      'quietHours': quietHours,
      'emergencyContactCount': emergencyContactCount,
    };
  }

  factory ProfileState.fromJson(Map<String, dynamic> json) {
    return ProfileState(
      userName: (json['userName'] as String? ?? '').trim(),
      handle: (json['handle'] as String? ?? '').trim(),
      city: (json['city'] as String? ?? '').trim(),
      helpfulnessScore: (json['helpfulnessScore'] as num? ?? 0).toInt(),
      helpfulVotesThisMonth: (json['helpfulVotesThisMonth'] as num? ?? 0)
          .toInt(),
      askRadiusMeters: (json['askRadiusMeters'] as num? ?? 300).toDouble(),
      broadcastRadiusKm: (json['broadcastRadiusKm'] as num? ?? 10).toDouble(),
      pushNotificationsEnabled:
          (json['pushNotificationsEnabled'] as bool?) ?? true,
      anonymousModeEnabled: (json['anonymousModeEnabled'] as bool?) ?? false,
      quietHours: (json['quietHours'] as String? ?? '').trim(),
      emergencyContactCount: (json['emergencyContactCount'] as num? ?? 0)
          .toInt(),
    );
  }

  ProfileState copyWith({
    String? userName,
    String? handle,
    String? city,
    int? helpfulnessScore,
    int? helpfulVotesThisMonth,
    double? askRadiusMeters,
    double? broadcastRadiusKm,
    bool? pushNotificationsEnabled,
    bool? anonymousModeEnabled,
    String? quietHours,
    int? emergencyContactCount,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      handle: handle ?? this.handle,
      city: city ?? this.city,
      helpfulnessScore: helpfulnessScore ?? this.helpfulnessScore,
      helpfulVotesThisMonth:
          helpfulVotesThisMonth ?? this.helpfulVotesThisMonth,
      askRadiusMeters: askRadiusMeters ?? this.askRadiusMeters,
      broadcastRadiusKm: broadcastRadiusKm ?? this.broadcastRadiusKm,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      anonymousModeEnabled: anonymousModeEnabled ?? this.anonymousModeEnabled,
      quietHours: quietHours ?? this.quietHours,
      emergencyContactCount:
          emergencyContactCount ?? this.emergencyContactCount,
    );
  }
}

class ProfileController extends Notifier<ProfileState> {
  static const String _localKey = 'profile_state';
  static const String _apiPath = '/profile';

  static const ProfileState _fallbackProfile = ProfileState(
    userName: 'Ahmad Siddiqui',
    handle: '@ahmad_geo',
    city: 'Karachi, PK',
    helpfulnessScore: 75,
    helpfulVotesThisMonth: 142,
    askRadiusMeters: 300,
    broadcastRadiusKm: 10,
    pushNotificationsEnabled: true,
    anonymousModeEnabled: false,
    quietHours: '11:00 PM - 7:00 AM',
    emergencyContactCount: 2,
  );

  @override
  ProfileState build() {
    return _fallbackProfile;
  }

  Future<void> initialize(BuildContext context) async {
    await _loadLocal(context);
    await _loadApi(context);
  }

  Future<void> _loadLocal(BuildContext context) async {
    final ApiResult<ProfileState> localResult =
        DataFlowService.loadLocal<ProfileState>(
          reader: _readLocalProfile,
          emptyMessage: 'No local profile cache found.',
        );

    if (!localResult.success || localResult.data == null) {
      return;
    }

    state = localResult.data!;
    AppMessaging.showInfo(context, 'Loaded profile from local storage.');
  }

  Future<void> _loadApi(BuildContext context) async {
    final ApiResult<ProfileState> apiResult =
        await DataFlowService.loadApi<ProfileState>(
          request: () => ApiService.instance.get(_apiPath),
          parser: _parseProfile,
        );

    if (!apiResult.success || apiResult.data == null) {
      AppMessaging.showWarning(
        context,
        apiResult.errorMessage ?? 'Could not sync profile from server.',
      );
      return;
    }

    state = apiResult.data!;
    await _saveLocal(state);
    AppMessaging.showSuccess(context, 'Profile synced from server.');
  }

  Future<void> createProfile({
    required BuildContext context,
    required Map<String, dynamic> payload,
  }) async {
    final ApiResult<dynamic> result = await ApiService.instance.post(
      _apiPath,
      data: payload,
    );

    if (!result.success) {
      AppMessaging.showError(
        context,
        result.errorMessage ?? 'Could not create profile.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Profile created successfully.');
    await _loadApi(context);
  }

  Future<void> updateProfile({
    required BuildContext context,
    required Map<String, dynamic> payload,
  }) async {
    final ApiResult<dynamic> result = await ApiService.instance.put(
      _apiPath,
      data: payload,
    );

    if (!result.success) {
      AppMessaging.showError(
        context,
        result.errorMessage ?? 'Could not update profile.',
      );
      return;
    }

    AppMessaging.showSuccess(context, 'Profile updated successfully.');
    await _loadApi(context);
  }

  Future<void> deleteProfile(BuildContext context) async {
    final ApiResult<dynamic> result = await ApiService.instance.delete(
      _apiPath,
    );

    if (!result.success) {
      AppMessaging.showError(
        context,
        result.errorMessage ?? 'Could not delete profile.',
      );
      return;
    }

    state = _fallbackProfile;
    await LocalStorageService.instance.delete(_localKey);
    AppMessaging.showSuccess(context, 'Profile deleted successfully.');
  }

  void setAskRadiusMeters(double value) {
    state = state.copyWith(askRadiusMeters: value);
    _saveLocal(state);
  }

  void setBroadcastRadiusKm(double value) {
    state = state.copyWith(broadcastRadiusKm: value);
    _saveLocal(state);
  }

  void togglePushNotifications(bool enabled) {
    state = state.copyWith(pushNotificationsEnabled: enabled);
    _saveLocal(state);
  }

  void toggleAnonymousMode(bool enabled) {
    state = state.copyWith(anonymousModeEnabled: enabled);
    _saveLocal(state);
  }

  ProfileState? _readLocalProfile() {
    final Map<dynamic, dynamic>? raw = LocalStorageService.instance
        .get<Map<dynamic, dynamic>>(_localKey);
    if (raw == null) {
      return null;
    }

    return ProfileState.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> _saveLocal(ProfileState value) async {
    final ApiResult<void> saveResult = await DataFlowService.saveLocal(
      writer: () => LocalStorageService.instance.put(_localKey, value.toJson()),
    );

    if (!saveResult.success) {
      // Do not block UX when cache write fails.
    }
  }

  ProfileState _parseProfile(dynamic payload) {
    final dynamic raw = payload is Map<String, dynamic>
        ? payload['data']
        : payload;
    if (raw is! Map<String, dynamic>) {
      return _fallbackProfile;
    }

    return ProfileState.fromJson(raw);
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

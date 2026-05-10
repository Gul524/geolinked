import 'package:geolinked/configs/providers/user_provider.dart';
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

  static const ProfileState _fallbackProfile = ProfileState(
    userName: 'User',
    handle: '@user',
    city: 'Location Not Set',
    helpfulnessScore: 0,
    helpfulVotesThisMonth: 0,
    askRadiusMeters: 300,
    broadcastRadiusKm: 10,
    pushNotificationsEnabled: true,
    anonymousModeEnabled: false,
    quietHours: '11:00 PM - 7:00 AM',
    emergencyContactCount: 0,
  );

  @override
  ProfileState build() {
    // Watch the global user provider for name/email
    final user = ref.watch(userProvider);
    
    return _fallbackProfile.copyWith(
      userName: user?.name ?? 'User',
      handle: '@${user?.name?.toLowerCase().replaceAll(' ', '_') ?? 'user'}',
    );
  }

  Future<void> initialize(BuildContext context) async {
    final raw = LocalStorageService.instance.get<Map<dynamic, dynamic>>(_localKey);
    if (raw != null) {
      state = ProfileState.fromJson(Map<String, dynamic>.from(raw));
    }
    
    // In a real app, we'd fetch extra profile data from Firestore here
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

  Future<void> _saveLocal(ProfileState value) async {
    await LocalStorageService.instance.put(_localKey, value.toJson());
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

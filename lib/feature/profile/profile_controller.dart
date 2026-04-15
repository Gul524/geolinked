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
  @override
  ProfileState build() {
    return const ProfileState(
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
  }

  void setAskRadiusMeters(double value) {
    state = state.copyWith(askRadiusMeters: value);
  }

  void setBroadcastRadiusKm(double value) {
    state = state.copyWith(broadcastRadiusKm: value);
  }

  void togglePushNotifications(bool enabled) {
    state = state.copyWith(pushNotificationsEnabled: enabled);
  }

  void toggleAnonymousMode(bool enabled) {
    state = state.copyWith(anonymousModeEnabled: enabled);
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

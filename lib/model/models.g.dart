// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  phone: json['phone'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  helpfulnessScore: (json['helpfulnessScore'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  settings: json['settings'] == null
      ? null
      : AppSettingsModel.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'phone': instance.phone,
  'isVerified': instance.isVerified,
  'helpfulnessScore': instance.helpfulnessScore,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'settings': instance.settings?.toJson(),
};

AskModel _$AskModelFromJson(Map<String, dynamic> json) => AskModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  status:
      $enumDecodeNullable(_$AskStatusEnumMap, json['status']) ??
      AskStatus.active,
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AskModelToJson(AskModel instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'status': _$AskStatusEnumMap[instance.status]!,
  'replyCount': instance.replyCount,
  'upvotes': instance.upvotes,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$AskStatusEnumMap = {
  AskStatus.active: 'active',
  AskStatus.resolved: 'resolved',
  AskStatus.closed: 'closed',
};

BroadcastModel _$BroadcastModelFromJson(Map<String, dynamic> json) =>
    BroadcastModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity:
          $enumDecodeNullable(_$BroadcastSeverityEnumMap, json['severity']) ??
          BroadcastSeverity.info,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 10,
      verifiedCount: (json['verifiedCount'] as num?)?.toInt() ?? 0,
      seenCount: (json['seenCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$BroadcastModelToJson(BroadcastModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'title': instance.title,
      'message': instance.message,
      'severity': _$BroadcastSeverityEnumMap[instance.severity]!,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusKm': instance.radiusKm,
      'verifiedCount': instance.verifiedCount,
      'seenCount': instance.seenCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

const _$BroadcastSeverityEnumMap = {
  BroadcastSeverity.info: 'info',
  BroadcastSeverity.medium: 'medium',
  BroadcastSeverity.high: 'high',
  BroadcastSeverity.critical: 'critical',
};

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  senderId: json['senderId'] as String,
  message: json['message'] as String,
  receiverId: json['receiverId'] as String?,
  type:
      $enumDecodeNullable(_$ChatMessageTypeEnumMap, json['type']) ??
      ChatMessageType.text,
  isRead: json['isRead'] as bool? ?? false,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  sentAt: json['sentAt'] == null
      ? null
      : DateTime.parse(json['sentAt'] as String),
);

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'message': instance.message,
  'type': _$ChatMessageTypeEnumMap[instance.type]!,
  'isRead': instance.isRead,
  'attachments': instance.attachments,
  'sentAt': instance.sentAt?.toIso8601String(),
};

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'text',
  ChatMessageType.image: 'image',
  ChatMessageType.audio: 'audio',
  ChatMessageType.system: 'system',
};

AppSettingsModel _$AppSettingsModelFromJson(
  Map<String, dynamic> json,
) => AppSettingsModel(
  themePreference:
      $enumDecodeNullable(_$ThemePreferenceEnumMap, json['themePreference']) ??
      ThemePreference.system,
  languageCode: json['languageCode'] as String? ?? 'en',
  askRadiusMeters: (json['askRadiusMeters'] as num?)?.toDouble() ?? 300,
  broadcastRadiusKm: (json['broadcastRadiusKm'] as num?)?.toDouble() ?? 10,
  pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
  anonymousModeEnabled: json['anonymousModeEnabled'] as bool? ?? false,
  locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? true,
  quietHoursStart: json['quietHoursStart'] as String?,
  quietHoursEnd: json['quietHoursEnd'] as String?,
);

Map<String, dynamic> _$AppSettingsModelToJson(AppSettingsModel instance) =>
    <String, dynamic>{
      'themePreference': _$ThemePreferenceEnumMap[instance.themePreference]!,
      'languageCode': instance.languageCode,
      'askRadiusMeters': instance.askRadiusMeters,
      'broadcastRadiusKm': instance.broadcastRadiusKm,
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
      'anonymousModeEnabled': instance.anonymousModeEnabled,
      'locationSharingEnabled': instance.locationSharingEnabled,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
    };

const _$ThemePreferenceEnumMap = {
  ThemePreference.system: 'system',
  ThemePreference.light: 'light',
  ThemePreference.dark: 'dark',
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

SignupRequest _$SignupRequestFromJson(Map<String, dynamic> json) =>
    SignupRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SignupRequestToJson(SignupRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  message: json['message'] as String,
  token: json['token'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'message': instance.message,
      'token': instance.token,
    };

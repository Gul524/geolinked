import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'models.g.dart';

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

@JsonSerializable(explicitToJson: true)
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.isVerified = false,
    this.helpfulnessScore = 0,
    this.createdAt,
    this.updatedAt,
    this.settings,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final bool isVerified;
  final int helpfulnessScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AppSettingsModel? settings;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonEnum(alwaysCreate: true)
enum AskStatus { active, resolved, closed }

@JsonSerializable(explicitToJson: true)
class AskModel {
  const AskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status = AskStatus.active,
    this.replyCount = 0,
    this.upvotes = 0,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final AskStatus status;
  final int replyCount;
  final int upvotes;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AskModel.fromJson(Map<String, dynamic> json) =>
      _$AskModelFromJson(json);

  Map<String, dynamic> toJson() => _$AskModelToJson(this);

  AskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    AskStatus? status,
    int? replyCount,
    int? upvotes,
    double? latitude,
    double? longitude,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      replyCount: replyCount ?? this.replyCount,
      upvotes: upvotes ?? this.upvotes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonEnum(alwaysCreate: true)
enum BroadcastSeverity { info, medium, high, critical }

@JsonSerializable(explicitToJson: true)
class BroadcastModel {
  const BroadcastModel({
    required this.id,
    required this.authorId,
    required this.category,
    required this.message,
    this.severity = BroadcastSeverity.info,
    this.latitude,
    this.longitude,
    this.radiusKm = 10,
    this.verifiedCount = 0,
    this.seenCount = 0,
    this.imageUrl,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String authorId;
  final String category;
  final String message;
  final BroadcastSeverity severity;
  final double? latitude;
  final double? longitude;
  final double radiusKm;
  final int verifiedCount;
  final int seenCount;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  factory BroadcastModel.fromJson(Map<String, dynamic> json) =>
      _$BroadcastModelFromJson(json);

  Map<String, dynamic> toJson() => _$BroadcastModelToJson(this);

  BroadcastModel copyWith({
    String? id,
    String? authorId,
    String? category,
    String? message,
    BroadcastSeverity? severity,
    double? latitude,
    double? longitude,
    double? radiusKm,
    int? verifiedCount,
    int? seenCount,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return BroadcastModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      category: category ?? this.category,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      verifiedCount: verifiedCount ?? this.verifiedCount,
      seenCount: seenCount ?? this.seenCount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

@JsonEnum(alwaysCreate: true)
enum ChatMessageType { text, image, audio, system }

@JsonSerializable(explicitToJson: true)
class ChatModel {
  const ChatModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    this.receiverId,
    this.type = ChatMessageType.text,
    this.isRead = false,
    this.attachments = const <String>[],
    this.sentAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String? receiverId;
  final String message;
  final ChatMessageType type;
  final bool isRead;
  final List<String> attachments;
  final DateTime? sentAt;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}

@JsonEnum(alwaysCreate: true)
enum ThemePreference { system, light, dark }

@JsonSerializable(explicitToJson: true)
class AppSettingsModel {
  const AppSettingsModel({
    this.themePreference = ThemePreference.system,
    this.languageCode = 'en',
    this.askRadiusMeters = 300,
    this.broadcastRadiusKm = 10,
    this.pushNotificationsEnabled = true,
    this.anonymousModeEnabled = false,
    this.locationSharingEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final ThemePreference themePreference;
  final String languageCode;
  final double askRadiusMeters;
  final double broadcastRadiusKm;
  final bool pushNotificationsEnabled;
  final bool anonymousModeEnabled;
  final bool locationSharingEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsModelToJson(this);
}

@JsonSerializable()
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class SignupRequest {
  const SignupRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  const AuthResponse({
    required this.userId,
    required this.name,
    required this.email,
    required this.message,
    required this.token,
  });

  final String userId;
  final String name;
  final String email;
  final String message;
  final String token;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

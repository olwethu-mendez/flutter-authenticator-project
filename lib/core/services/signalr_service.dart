import 'dart:async';

import 'package:authentipass/core/api/app_config.dart';
import 'package:authentipass/core/services/signal_r/exponential_retry_policy.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/iretry_policy.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  final AuthLocalDataSource localDataSource;
  HubConnection? _hubConnection;

  // Multiple controllers for different concerns
  final _statusController = StreamController<UserStatusMessage>.broadcast();
  final _notifController = StreamController<AppNotification>.broadcast();
  final _sysController = StreamController<SystemMessage>.broadcast();

  Stream<UserStatusMessage> get statusStream => _statusController.stream;
  Stream<AppNotification> get notificationStream => _notifController.stream;
  Stream<SystemMessage> get systemStream => _sysController.stream;

  SignalRService(this.localDataSource);

  Future<void> initHub() async {
    if (_hubConnection?.state == HubConnectionState.Connected) return;

    final token = await localDataSource.getCachedToken();
    if (token == null) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          AppConfig.notificationsHub,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            skipNegotiation:
                true, // Optional: Improves performance if using WebSockets
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect(reconnectPolicy: ExponentialRetryPolicy())
        .build();

    _hubConnection?.on("ReceiveAccountStatus", (args) {
      final data = args![0] as Map<String, dynamic>;
      _statusController.add(UserStatusMessage.fromJson(data));
      if (kDebugMode) {
        print("${_hubConnection?.state?.name}: ${data['message']}");
      }
    });

    _hubConnection?.on("ReceiveNotification", (args) {
      final data = args![0] as Map<String, dynamic>;
      _notifController.add(AppNotification.fromJson(data));
      if (kDebugMode) {
        print("${_hubConnection?.state?.name}: ${data['title']}");
      }
    });

    try {
      await _hubConnection?.start();
    } catch (e) {
      if (kDebugMode) print("SignalR Start Error: $e");
      if (e.toString().contains("401")) {
      // Logic to trigger your RefreshTokenUseCase
      // Then call initHub() again
    }
    }
  }

  void stop() async {
    await _hubConnection?.stop();
    if (kDebugMode) print("hub connection stopped");
  }
}

class UserStatusMessage {
  UserStatusMessage({
    required this.userId,
    required this.isDeactivated,
    required this.message,
  });

  final String userId;
  final bool isDeactivated;
  final String message;
  factory UserStatusMessage.fromJson(Map<String, dynamic> json) {
    return UserStatusMessage(
      userId: json['userId'] as String, // Match your C# GetProfileDto
      isDeactivated: json['isDeactivated'] as bool,
      message: json['message'] as String, // Match your C# GetProfileDto
    );
  }

  Map<String, String> toJson() {
    return {
      'userId': userId,
      'isDeactivated': isDeactivated.toString(),
      'message': message,
    };
  }
}

class AppNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  AppNotification({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json['title'] as String, // Match your C# GetProfileDto
      body: json['body'] as String,
      timestamp: json['timestamp'] as DateTime, // Match your C# GetProfileDto
    );
  }

  Map<String, String> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SystemMessage {
  final String? message;
  SystemMessage({this.message});
}

import 'dart:async';

import 'package:authentipass/core/api/app_config.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  final AuthLocalDataSource localDataSource;
  HubConnection? _hubConnection;
  final _statusController = StreamController<UserStatusMessage>.broadcast();
  Stream<UserStatusMessage> get statusStream => _statusController.stream;

  SignalRService(this.localDataSource);

  Future<void> initHub() async {
    final token = await localDataSource.getCachedToken();
    if (token == null) return;


    _hubConnection = HubConnectionBuilder()
        .withUrl(
          AppConfig.usersHub,
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on("ReceiveAccountStatus", (arguments) {
      final Map<dynamic, dynamic> data = arguments![0] as Map<String, dynamic>;
      _statusController.add(
        UserStatusMessage(
          data['userId'].toString(), // Ensure your C# sends this back!
          data['isDeactivated'] as bool,
          data['message'].toString(),
        ),
      );
      if (kDebugMode) {
        print("${_hubConnection?.state?.name}: ${data['message']}");
      }
    });

    if (kDebugMode) print(_hubConnection?.baseUrl);
    await _hubConnection?.start();
  }

  void stop() async {
    await _hubConnection?.stop();
    if (kDebugMode) print("hub connection stopped");
  }
}

class UserStatusMessage {
  final String userId;
  final bool isDeactivated;
  final String message;
  UserStatusMessage(this.userId, this.isDeactivated, this.message);
}

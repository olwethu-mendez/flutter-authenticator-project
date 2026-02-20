import 'dart:async';

import 'package:authentipass/core/api/app_config.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
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
          "${AppConfig.apiBaseUrl}/userHub",
          options: HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on("ReceiveAccountStatus", (arguments) {
      final data = arguments![0] as Map<String, dynamic>;
      _statusController.add(
        UserStatusMessage(
          data['userId'], // Ensure your C# sends this back!
          data['isDeactivated'],
        ),
      );
    });

    await _hubConnection?.start();
  }

  void stop() => _hubConnection?.stop();
}

class UserStatusMessage {
  final String userId;
  final bool isDeactivated;
  UserStatusMessage(this.userId, this.isDeactivated);
}

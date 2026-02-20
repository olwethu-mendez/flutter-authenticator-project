import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class GetBiometricSettingsRequested extends SettingsEvent{}
class SetBiometricSettingsRequested extends SettingsEvent{
  final bool enabling;

  const SetBiometricSettingsRequested({required this.enabling});
  @override
  List<Object?> get props => [enabling];
}

class ResetSettingsFlagsEvent extends SettingsEvent {}
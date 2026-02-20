import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState{}

class SettingsLoading extends SettingsState{}
class SettingsStatus extends SettingsState {
  final bool bioAuthEnabled;
  final bool isUpdate; // Add this flag

  const SettingsStatus({
    required this.bioAuthEnabled, 
    this.isUpdate = false, // Default to false for initial loads
  });

  @override
  List<Object?> get props => [bioAuthEnabled, isUpdate];
}
class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
}

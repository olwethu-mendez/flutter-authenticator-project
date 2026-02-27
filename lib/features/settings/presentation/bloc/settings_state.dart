import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState{}

class SettingsLoading extends SettingsState{}
class SettingsStatus extends SettingsState {
  final bool bioSupported;
  final bool bioAuthEnabled;
  final bool isUpdate; // Add this flag

  const SettingsStatus({
    required this.bioAuthEnabled, 
    this.bioSupported = false, // Default
    this.isUpdate = false, // Default to false for initial loads
  });

  @override
  List<Object?> get props => [bioAuthEnabled, bioSupported, isUpdate];

  // Helper to copy state easily
  SettingsStatus copyWith({
    bool? bioAuthEnabled,
    bool? biometricSupported,
    bool? isUpdate,
  }) {
    return SettingsStatus(
      bioAuthEnabled: bioAuthEnabled ?? this.bioAuthEnabled,
      bioSupported: biometricSupported ?? bioSupported,
      isUpdate: isUpdate ?? this.isUpdate,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
}

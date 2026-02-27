import 'dart:async';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/settings/domain/usecases/get_biometric_settings_usecase.dart';
import 'package:authentipass/features/settings/domain/usecases/set_biometric_settings_usecase.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_event.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetBiometricSettingsUsecase getBiometricSettingsUsecase;
  final SetBiometricSettingsUsecase setBiometricSettingsUsecase;

  SettingsBloc({
    required this.getBiometricSettingsUsecase,
    required this.setBiometricSettingsUsecase
  }) : super(SettingsInitial()){
    on<GetBiometricSettingsRequested>(_onGetBiometricSettingsRequested);
    on<SetBiometricSettingsRequested>(_onSetBiometricSettingsRequested);
    on<ResetSettingsFlagsEvent>(_onResetSettingsFlagsEvent);
  }

  Future<void> _onGetBiometricSettingsRequested(
    GetBiometricSettingsRequested event, Emitter<SettingsState> emit) async {
  emit(SettingsLoading());

  // 1. Check Hardware Support
  final auth = LocalAuthentication();
  final bool isHardwareSupported = await auth.isDeviceSupported();
  final List<BiometricType> available = await auth.getAvailableBiometrics();
  final bool hasHardware = isHardwareSupported && available.isNotEmpty;

  // 2. Check User Preference
  final result = await getBiometricSettingsUsecase(NoParams());

  result.fold(
    (failure) => emit(SettingsError(failure.message)),
    (enabled) => emit(SettingsStatus(
      bioAuthEnabled: enabled ?? false,
      bioSupported: hasHardware, // Now the UI knows both!
      isUpdate: false,
    )),
  );
}

  Future<void> _onSetBiometricSettingsRequested(SetBiometricSettingsRequested event, Emitter<SettingsState> emit) async {
    // Capture the current support status before emitting Loading
  bool currentlySupported = false;
  if (state is SettingsStatus) {
    currentlySupported = (state as SettingsStatus).bioSupported;
  }

    emit(SettingsLoading());

    final result = await setBiometricSettingsUsecase(event.enabling);
result.fold(
    (failure) => emit(SettingsError(failure.message)),
    (_) => emit(SettingsStatus(
      bioAuthEnabled: event.enabling, 
      bioSupported: currentlySupported, // Pass the support flag back!
      isUpdate: true,
    )),
  );
  }

  Future<void> _onResetSettingsFlagsEvent(ResetSettingsFlagsEvent event, Emitter<SettingsState> emit) async {
    final currentState = state;
    if (currentState is SettingsStatus) {
      emit(SettingsStatus(bioAuthEnabled: currentState.bioAuthEnabled, isUpdate: false));
    }
  }
}
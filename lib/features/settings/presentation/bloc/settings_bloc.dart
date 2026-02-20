import 'dart:async';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/settings/domain/usecases/get_biometric_settings_usecase.dart';
import 'package:authentipass/features/settings/domain/usecases/set_biometric_settings_usecase.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_event.dart';
import 'package:authentipass/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Future<void> _onGetBiometricSettingsRequested(GetBiometricSettingsRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    final result = await getBiometricSettingsUsecase(NoParams());
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (success) => emit(SettingsStatus(bioAuthEnabled: success ?? false, isUpdate: false))
      // success ?? false ensures that if the cache is empty, it defaults to List
    );
  }

  Future<void> _onSetBiometricSettingsRequested(SetBiometricSettingsRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());

    final result = await setBiometricSettingsUsecase(event.enabling);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) => emit(SettingsStatus(bioAuthEnabled: event.enabling, isUpdate: true))
    );
  }

  Future<void> _onResetSettingsFlagsEvent(ResetSettingsFlagsEvent event, Emitter<SettingsState> emit) async {
    final currentState = state;
    if (currentState is SettingsStatus) {
      emit(SettingsStatus(bioAuthEnabled: currentState.bioAuthEnabled, isUpdate: false));
    }
  }
}
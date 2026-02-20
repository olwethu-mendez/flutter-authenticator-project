import 'dart:async';
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/services/signalr_service.dart';
import 'package:authentipass/features/user_details/domain/usecases/admin_deactivates_user_usecase.dart';
import 'package:authentipass/features/user_details/domain/usecases/get_single_user_usecase.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_event.dart';
import 'package:authentipass/features/user_details/presentation/bloc/user_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  final GetSingleUserUsecase getSingleUserUsecase;
  final AdminDeactivatesUserUsecase adminDeactivatesUserUsecase;

  final SignalRService _signalRService;
  StreamSubscription? _signalRSubscription;

  UserDetailsBloc({
    required this.getSingleUserUsecase,
    required this.adminDeactivatesUserUsecase,
    required SignalRService signalRService,
  }) : _signalRService = signalRService,
       super(UserDetailsInitial()) {
    on<UserDetailsRequested>(_onGetSingleUserRequested);
    on<AdminDeactivatesUserRequested>(_onAdminDeactivatesUserRequested);

    // Listen to SignalR events
    // features/user_details/presentation/bloc/user_details_bloc.dart

    _signalRSubscription = _signalRService.statusStream.listen((message) {
      // If the user being banned is the one currently displayed on this screen
      if (state is UserDetailsLoaded) {
        final currentViewedUser = (state as UserDetailsLoaded).user;
        if (currentViewedUser.userId == message.userId) {
          // Refresh the data so the "Ban" button changes to "Unban" in real-time
          add(UserDetailsRequested(userId: message.userId));
        }
      }
    });
  }

  Future<void> _onGetSingleUserRequested(
    UserDetailsRequested event,
    Emitter<UserDetailsState> emit,
  ) async {
    emit(UserDetailsLoading());

    final result = await getSingleUserUsecase(event.userId);
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (success) => emit(UserDetailsLoaded(success)),
    );
  }

  Future<void> _onAdminDeactivatesUserRequested(
    AdminDeactivatesUserRequested event,
    Emitter<UserDetailsState> emit,
  ) async {
    emit(UserDeactivating());

    final result = await adminDeactivatesUserUsecase(event.userId);
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (success) => success == "activated"
          ? emit(UserActivated(success))
          : emit(UserDeactivated(success)),
    );
  }

  // Helper to clean up error messages
  UserDetailsState _mapFailureToState(Failure failure) {
    return UserDetailsError(failure.message);
  }
}

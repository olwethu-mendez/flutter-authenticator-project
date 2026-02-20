import 'dart:async';

import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/users_management/domain/usecases/create_users_usecase.dart';
import 'package:authentipass/features/users_management/domain/usecases/get_users_usecase.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_event.dart';
import 'package:authentipass/features/users_management/presentation/bloc/users_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUsecase getUsersUsecase;
  final CreateUserUseCase createUserUsecase;

  UsersBloc({
    required this.getUsersUsecase,
    required this.createUserUsecase
  }) : super(UsersInitial()){
    on<GetUsersRequested>(_onGetUsersRequested);
    on<CreateUserRequested>(_onCreateUserRequested);
  }

  Future<void> _onGetUsersRequested(GetUsersRequested event, Emitter<UsersState> emit) async {
    emit(UsersLoading());

    final result = await getUsersUsecase(NoParams());
    result.fold(
      (failure) => emit(_mapFailureToState(failure)), 
      (success) => emit(UsersLoaded(success)),
    );
  }

  Future<void> _onCreateUserRequested(CreateUserRequested event, Emitter<UsersState> emit) async {
    emit(UsersLoading());

    final result = await createUserUsecase(event.createUser);
    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (success) => emit(UserCreated()));
  }
  
  // Helper to clean up error messages
  UsersState _mapFailureToState(Failure failure) {
    // Instead of hardcoding "Invalid data provided", use the message from the API!
    return UsersError(failure.message);
  }
}
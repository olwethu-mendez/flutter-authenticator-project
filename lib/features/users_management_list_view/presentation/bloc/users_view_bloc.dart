import 'dart:async';

import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/users_management_list_view/domain/usecases/get_view_usecase.dart';
import 'package:authentipass/features/users_management_list_view/domain/usecases/set_view_usecase.dart';
import 'package:authentipass/features/users_management_list_view/presentation/bloc/users_view_state.dart';
import 'package:authentipass/features/users_management_list_view/presentation/bloc/users_view_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersViewBloc extends Bloc<UsersViewEvent, UsersViewState> {
  final GetViewUsecase getViewUsecase;
  final SetViewUsecase setViewUsecase;

  UsersViewBloc({
    required this.getViewUsecase,
    required this.setViewUsecase
  }) : super(ViewInitial()){
    on<GetViewsRequested>(_onGetViewsRequested);
    on<SetViewsRequested>(_onSetViewsRequested);
  }
  
  // Helper to clean up error messages
  UsersViewState _mapFailureToState(Failure failure) {
    // Instead of hardcoding "Invalid data provided", use the message from the API!
    return ViewError(failure.message);
  }

  Future<void> _onGetViewsRequested(GetViewsRequested event, Emitter<UsersViewState> emit) async {
    emit(ViewLoading());

    final result = await getViewUsecase(NoParams());
    result.fold(
      (failure) => emit(_mapFailureToState(failure)), 
      (success) => (success ?? false) ? emit(IsGrid()) : emit(IsList())
      // success ?? false ensures that if the cache is empty, it defaults to List
    );
  }

  Future<void> _onSetViewsRequested(SetViewsRequested event, Emitter<UsersViewState> emit) async {
    emit(ViewLoading());

    final result = await setViewUsecase(event.isGrid);
    result.fold(
      (failure) => emit(_mapFailureToState(failure)), 
      (_) => emit(event.isGrid ? IsGrid() : IsList())
    );
  }
}
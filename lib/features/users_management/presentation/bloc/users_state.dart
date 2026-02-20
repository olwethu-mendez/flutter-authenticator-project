import 'package:authentipass/features/users_management/domain/entities/users_list_entity.dart';
import 'package:equatable/equatable.dart';

abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState{}

class UsersLoading extends UsersState{}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
}

class UsersLoaded extends UsersState {
  final List<UsersListEntity> users;
  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserCreated extends UsersState {}

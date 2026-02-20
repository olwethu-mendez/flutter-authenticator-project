import 'package:authentipass/features/users_management/data/models/create_user_model.dart';
import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class GetUsersRequested extends UsersEvent{}

class CreateUserRequested extends UsersEvent{
  final CreateUserModel createUser;

  const CreateUserRequested({required this.createUser});

  @override
  List<Object?> get props => [createUser];
}
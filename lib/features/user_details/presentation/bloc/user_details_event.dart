import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:equatable/equatable.dart';

abstract class UserDetailsEvent extends Equatable {
  const UserDetailsEvent();

  @override
  List<Object?> get props => [];
}

class UserDetailsUpdated extends UserDetailsEvent {
  final UserProfileModel user;
  const UserDetailsUpdated(this.user);
}


class UserDetailsRequested extends UserDetailsEvent{
  final String userId;

  const UserDetailsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AdminDeactivatesUserRequested extends UserDetailsEvent{
  final String userId;

  const AdminDeactivatesUserRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
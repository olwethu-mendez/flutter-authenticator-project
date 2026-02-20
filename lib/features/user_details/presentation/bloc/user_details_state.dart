import 'package:authentipass/features/user_details/domain/entities/get_user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class UserDetailsState extends Equatable {
  const UserDetailsState();
  @override
  List<Object?> get props => [];
}

class UserDetailsInitial extends UserDetailsState{}
class UserDetailsLoading extends UserDetailsState{}

class UserDetailsLoaded extends UserDetailsState {
  final GetUserEntity user;
  const UserDetailsLoaded(this.user);

  @override
  List<Object?> get props => [user];
}
class UserDeactivating extends UserDetailsState{}

class UserDeactivated extends UserDetailsState {
  final String deactivated;
  const UserDeactivated(this.deactivated);

  @override
  List<Object?> get props => [deactivated];
}
class UserAactivating extends UserDetailsState{}

class UserActivated extends UserDetailsState {
  final String activated;
  const UserActivated(this.activated);

  @override
  List<Object?> get props => [activated];
}
class UserDetailsError extends UserDetailsState {
  final String message;
  const UserDetailsError(this.message);
}

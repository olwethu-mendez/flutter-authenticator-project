import 'package:equatable/equatable.dart';

abstract class UsersViewState extends Equatable {
  const UsersViewState();
  @override
  List<Object?> get props => [];
}

class ViewInitial extends UsersViewState{}

class ViewLoading extends UsersViewState{}
class IsList extends UsersViewState{}
class IsGrid extends UsersViewState{}

class ViewError extends UsersViewState {
  final String message;
  const ViewError(this.message);
}

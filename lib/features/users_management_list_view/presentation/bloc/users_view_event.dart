import 'package:equatable/equatable.dart';

abstract class UsersViewEvent extends Equatable {
  const UsersViewEvent();

  @override
  List<Object?> get props => [];
}

class GetViewsRequested extends UsersViewEvent{}
class SetViewsRequested extends UsersViewEvent{
  final bool isGrid;

  const SetViewsRequested({required this.isGrid});

  @override
  List<Object?> get props => [isGrid];
}
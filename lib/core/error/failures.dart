import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}
class ServerFailure extends Failure{
  const ServerFailure([super.message = "Server Error"]);
}
class CacheFailure extends Failure{  
  const CacheFailure([super.message = "Cache Error"]);
}
class InvalidRequestFailure extends Failure{
  const InvalidRequestFailure([super.message = "Bad Request Error"]);
  }
class InvalidCredentialsFailure extends Failure{
  const InvalidCredentialsFailure([super.message = "Unauthorized Error"]);
  }
class TimeoutFailure extends Failure{
  const TimeoutFailure([super.message = "Timeout Error"]);
  }
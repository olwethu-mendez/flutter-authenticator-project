import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/user_details/domain/entities/get_user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class UserDetailsRepository {
  Future<Either<Failure,GetUserEntity>> getSingleUser(String userId);
  Future<Either<Failure,String>> adminDeactivatesUser(String userId);
}
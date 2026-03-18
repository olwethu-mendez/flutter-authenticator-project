import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/users_management/data/models/users_filtered_list_model.dart';
import 'package:authentipass/features/users_management/domain/entities/create_user_entity.dart';
import 'package:authentipass/features/users_management/domain/entities/users_list_entity.dart';
import 'package:dartz/dartz.dart';

abstract class UsersRepository {
  Future<Either<Failure,List<UsersListEntity>>> getUsers();
  Future<Either<Failure,List<UsersFilteredListModel>>> getFilteredUsers(String? fullName, String? email, String? phoneNumebr);
  Future<Either<Failure,void>> createUser(CreateUserEntity createUser);
}
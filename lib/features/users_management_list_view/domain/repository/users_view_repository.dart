import 'package:authentipass/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class UsersViewRepository {
  Future<Either<Failure,void>> setListView(bool isGrid);
  Future<Either<Failure,bool?>> getListView();
}
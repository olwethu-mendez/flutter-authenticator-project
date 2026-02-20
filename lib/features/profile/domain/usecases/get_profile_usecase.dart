// features/profile/domain/usecases/get_profile_usecase.dart
import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/profile/data/models/user_profile_model.dart';
import 'package:authentipass/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetProfileUseCase implements UseCases<UserProfileModel, NoParams> {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfileModel>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
// features/profile/domain/usecases/create_profile_usecase.dart
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/profile_repository.dart';
import '../../data/models/create_profile_model.dart';

class CreateProfileUseCase implements UseCases<AuthResultsModel, CreateProfileModel> {
  final ProfileRepository repository;
  CreateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResultsModel>> call(CreateProfileModel params) async {
    return await repository.createProfile(params);
  }
}
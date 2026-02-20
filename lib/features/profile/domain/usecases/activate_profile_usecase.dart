// features/profile/domain/usecases/create_profile_usecase.dart
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/profile_repository.dart';

class ActivateProfileUseCase implements UseCases<AuthResultsModel, DeactivateAccountModel> {
  final ProfileRepository repository;
  ActivateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResultsModel>> call(DeactivateAccountModel params) async {
    return await repository.activateProfile(params);
  }
  
}
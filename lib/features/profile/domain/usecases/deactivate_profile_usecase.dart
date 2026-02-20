// features/profile/domain/usecases/create_profile_usecase.dart
import 'package:authentipass/features/profile/data/models/deactivate_account_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/profile_repository.dart';

class DeactivateProfileUseCase implements UseCases<void, DeactivateAccountModel> {
  final ProfileRepository repository;
  DeactivateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeactivateAccountModel params) async {
    return await repository.deactivateProfile(params);
  }
}
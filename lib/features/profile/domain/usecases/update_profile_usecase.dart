// features/profile/domain/usecases/create_profile_usecase.dart
import 'package:authentipass/features/profile/data/models/update_profile_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/profile_repository.dart';

class UpdateProfileUseCase implements UseCases<void, UpdateProfileModel> {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileModel params) async {
    return await repository.updateProfile(params);
  }
}
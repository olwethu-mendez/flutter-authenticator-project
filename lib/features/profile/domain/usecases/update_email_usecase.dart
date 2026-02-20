// features/profile/domain/usecases/update_email_usecase.dart
import 'package:authentipass/features/profile/data/models/update_email_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/profile_repository.dart';

class UpdateEmailUseCase implements UseCases<void, UpdateEmailModel> {
  final ProfileRepository repository;
  UpdateEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateEmailModel params) async {
    return await repository.updateEmail(params);
  }
}
// features/profile/domain/usecases/create_profile_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/profile_repository.dart';

class UpdateProfilePictureUseCase implements UseCases<void, File?> {
  final ProfileRepository repository;
  UpdateProfilePictureUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(File? params) async {
    return await repository.updateProfilePicture(params);
  }
}
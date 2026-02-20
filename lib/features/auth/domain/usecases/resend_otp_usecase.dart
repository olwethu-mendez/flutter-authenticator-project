import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ResendOtpUsecase implements UseCases<void, bool>{
  final AuthRepository repository;

  ResendOtpUsecase({required this.repository});

  @override
  Future<Either<Failure,void>> call(bool isEmail) async {
    return await repository.resendOtp(isEmail);
  }
}
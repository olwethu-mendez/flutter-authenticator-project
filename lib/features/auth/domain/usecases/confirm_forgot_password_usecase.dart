import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/core/usecases/usecase.dart';
import 'package:authentipass/features/auth/domain/entity/forgot_password_entity.dart';
import 'package:authentipass/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class ConfirmForgotPasswordUsecase implements UseCases<void, ForgotPasswordParams>{
  final AuthRepository repository;

  ConfirmForgotPasswordUsecase({required this.repository});

  @override
  Future<Either<Failure,void>> call(ForgotPasswordParams params) async {
    return await repository.confirmForgotPassword(params.forgotPassword);
  }
}

class ForgotPasswordParams extends Equatable{
  final ForgotPasswordEntity forgotPassword;

  const ForgotPasswordParams({required this.forgotPassword});

  @override
  List<Object> get props => [forgotPassword];
}
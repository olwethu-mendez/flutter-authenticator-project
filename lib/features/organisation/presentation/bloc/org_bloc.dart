import 'dart:async';

import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/organisation/data/models/get_my_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisations_model.dart';
import 'package:authentipass/features/organisation/domain/repository/organisation_repository.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_event.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_state.dart';
import 'package:authentipass/features/users_management/domain/repository/users_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrgBloc extends Bloc<OrgEvent, OrgState> {
  final OrganisationRepository repository;
  final UsersRepository userRepository;
  final AuthLocalDataSource localDataSource;
  final AuthBloc authBloc;

  OrgBloc({
    required this.repository,
    required this.userRepository,
    required this.localDataSource,
    required this.authBloc,
  }) : super(OrgInitial()) {
    on<CreateOrganisationsRequested>(_onCreateOrganisation);
    on<GetMyOrganisationsRequested>(_onGetMyOrganisations);
    on<GetPublicOrganisationsRequested>(_onGetPublicOrganisations);
    on<GetOrganisationsRequested>(_onGetOrganisations);
    on<GetAllOrganisationsRequested>(_onGetAllOrganisationsRequested);
    on<GetOrganisationRequested>(_onGetOrganisation);
    on<AcceptInvitationRequested>(_onAcceptInvitation);
    on<InviteUserToOrganisationRequested>(_onInviteUserToOrganisatio);
    on<SwitchOrganisationRequested>(_onSwitchOrganisation);
    on<GetInvitableUsersRequested>(_onGetInvitableUsers);
    on<ClearOrgSearchRequested>(_onClearOrgSearchRequested);
  }

  Future<void> _onCreateOrganisation(
    CreateOrganisationsRequested event,
    Emitter<OrgState> emit,
  ) async {
    emit(OrgLoading());
    final result = await repository.createOrganisation(
      event.createOrganisationModel,
    );

    await result.fold((failure) async => emit(OrgError(failure.message)), (
      success,
    ) async {
      // 1. Cache the new token containing the new 'ActiveOrg' claim
      await localDataSource.cacheToken(success.token!);
      await localDataSource.cacheRefreshToken(success.refreshToken!);
      //await localDataSource.cacheActiveOrgId(event);
      // 2. Notify AuthBloc so it decodes the new token and updates UI/Permissions
      authBloc.add(AuthCheckRequested());

      // 3. Refresh the list
      add(GetMyOrganisationsRequested());
    });
  }

  Future<void> _onGetMyOrganisations(
    GetMyOrganisationsRequested event,
    Emitter<OrgState> emit,
  ) async {
    final currentState = state;
    emit(OrgLoading());
    final activeId = await localDataSource.getActiveOrgId();
    final result = await repository.getMyOrganisations();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(
        OrgLoaded(
          myOrganisations: success,
          // PRESERVE existing my organisations if they exist
          organisation: currentState is OrgLoaded
              ? currentState.organisation
              : null,
          organisations: currentState is OrgLoaded
              ? currentState.organisations
              : null,
          publicOrganisations: currentState is OrgLoaded
              ? currentState.publicOrganisations
              : null,
          //invitableUsers: currentState is OrgLoaded ? currentState.invitableUsers : null,
          activeOrgId: activeId,
        ),
      ),
    );
  }

  Future<void> _onGetPublicOrganisations(
    GetPublicOrganisationsRequested event,
    Emitter<OrgState> emit,
  ) async {
    final currentState = state;
    emit(OrgLoading());
    final activeId = await localDataSource.getActiveOrgId();
    final result = await repository.getPublicOrganisations();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(
        OrgLoaded(
          publicOrganisations: success,
          // PRESERVE existing my organisations if they exist
          organisation: currentState is OrgLoaded
              ? currentState.organisation
              : null,
          organisations: currentState is OrgLoaded
              ? currentState.organisations
              : null,
          myOrganisations: currentState is OrgLoaded
              ? currentState.myOrganisations
              : null,
          //invitableUsers: currentState is OrgLoaded ? currentState.invitableUsers : null,
          activeOrgId: activeId,
        ),
      ),
    );
  }

  Future<void> _onGetOrganisations(
    GetOrganisationsRequested event,
    Emitter<OrgState> emit,
  ) async {
    final currentState = state;
    emit(OrgLoading());
    final activeId = await localDataSource.getActiveOrgId();
    final result = await repository.getPublicOrganisations();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(
        OrgLoaded(
          organisations: success,
          // PRESERVE existing my organisations if they exist
          publicOrganisations: currentState is OrgLoaded
              ? currentState.publicOrganisations
              : null,
          organisation: currentState is OrgLoaded
              ? currentState.organisation
              : null,
          myOrganisations: currentState is OrgLoaded
              ? currentState.myOrganisations
              : null,
          //invitableUsers: currentState is OrgLoaded ? currentState.invitableUsers : null,
          activeOrgId: activeId,
        ),
      ),
    );
  }

  Future<void> _onGetOrganisation(
    GetOrganisationRequested event,
    Emitter<OrgState> emit,
  ) async {
    final currentState = state;
    emit(OrgLoading());
    final result = await repository.getOrganisation(event.organisationId);
    final activeId = await localDataSource.getActiveOrgId();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(
        OrgLoaded(
          organisation: success,
          // PRESERVE existing my organisations if they exist
          organisations: currentState is OrgLoaded
              ? currentState.organisations
              : null,
          myOrganisations: currentState is OrgLoaded
              ? currentState.myOrganisations
              : null,
          publicOrganisations: currentState is OrgLoaded
              ? currentState.publicOrganisations
              : null,
          //invitableUsers: currentState is OrgLoaded ? currentState.invitableUsers : null,
          activeOrgId: activeId,
        ),
      ),
    );
  }

  Future<void> _onAcceptInvitation(
    AcceptInvitationRequested event,
    Emitter<OrgState> emit,
  ) async {
    emit(OrgLoading());
    final result = await repository.acceptInvitation(
      event.organisationId,
      event.invitationAccepted,
    );

    await result.fold((failure) async => emit(OrgError(failure.message)), (
      success,
    ) async {
      // 1. Cache the new token containing the new 'ActiveOrg' claim
      await localDataSource.cacheToken(success.token!);
      await localDataSource.cacheRefreshToken(success.refreshToken!);
      await localDataSource.cacheActiveOrgId(event.organisationId);
      // 2. Notify AuthBloc so it decodes the new token and updates UI/Permissions
      authBloc.add(AuthCheckRequested());

      // 3. Refresh the list
      add(GetMyOrganisationsRequested());
    });
  }

  Future<void> _onInviteUserToOrganisatio(
    InviteUserToOrganisationRequested event,
    Emitter<OrgState> emit,
  ) async {
    final currentState = state;
    final result = await repository.inviteUserToOrganisation(event.profileId);

    await result.fold((failure) async => emit(OrgError(failure.message)), (
      success,
    ) async {
      // Success! Keep the current list, but maybe show a snackbar (via BlocListener in UI)
      if (currentState is OrgLoaded) {
        emit(currentState);
      }
      add(GetMyOrganisationsRequested()); // Refresh the lists
    });
  }

  Future<void> _onSwitchOrganisation(
    SwitchOrganisationRequested event,
    Emitter<OrgState> emit,
  ) async {
    emit(OrgLoading());
    final result = await repository.switchOrganisation(event.organisationId);

    await result.fold((failure) async => emit(OrgError(failure.message)), (
      success,
    ) async {
      // 1. Cache the new token containing the new 'ActiveOrg' claim
      await localDataSource.cacheToken(success.token!);
      await localDataSource.cacheRefreshToken(success.refreshToken!);
      await localDataSource.cacheActiveOrgId(event.organisationId);
      // 2. Notify AuthBloc so it decodes the new token and updates UI/Permissions
      authBloc.add(AuthCheckRequested());

      // 3. Refresh the list
      add(GetAllOrganisationsRequested());
    });
  }

  Future<void> _onGetInvitableUsers(
    GetInvitableUsersRequested event,
    Emitter<OrgState> emit,
  ) async {
    final currentState = state;
    emit(OrgLoading());
    final result = await userRepository.getFilteredUsers(
      event.fullName,
      event.email,
      event.phoneNumber,
    );
    final activeId = await localDataSource.getActiveOrgId();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(
        OrgLoaded(
          invitableUsers: success,
          // PRESERVE existing my organisations if they exist
          organisation: currentState is OrgLoaded
              ? currentState.organisation
              : null,
          organisations: currentState is OrgLoaded
              ? currentState.organisations
              : null,
          myOrganisations: currentState is OrgLoaded
              ? currentState.myOrganisations
              : null,
          publicOrganisations: currentState is OrgLoaded
              ? currentState.publicOrganisations
              : null,
          activeOrgId: activeId,
        ),
      ),
    );
  }

  Future<void> _onClearOrgSearchRequested(
    ClearOrgSearchRequested event,
    Emitter<OrgState> emit,
  ) async {
    final currentState = state;
    final activeId = await localDataSource.getActiveOrgId();
    emit(
      OrgLoaded(
        invitableUsers: null,
        // PRESERVE existing my organisations if they exist
        organisation: currentState is OrgLoaded
            ? currentState.organisation
            : null,
        organisations: currentState is OrgLoaded
            ? currentState.organisations
            : null,
        myOrganisations: currentState is OrgLoaded
            ? currentState.myOrganisations
            : null,
        publicOrganisations: currentState is OrgLoaded
            ? currentState.publicOrganisations
            : null,
        activeOrgId: activeId,
      ),
    );
  }

Future<void> _onGetAllOrganisationsRequested(
    GetAllOrganisationsRequested event, Emitter<OrgState> emit) async {
  
  final currentState = state;
  
  // 1. Only show the full screen loader if we have absolutely nothing
  if (currentState is! OrgLoaded) {
    emit(OrgLoading());
  }

  // 2. Fetch all data in parallel for speed
  final results = await Future.wait([
    localDataSource.getActiveOrgId(),
    repository.getOrganisations(),        // Joined
    repository.getMyOrganisations(),      // Managed
    repository.getPublicOrganisations(),  // Public
  ]);

  final activeId = results[0] as String?;
  final joinedResult = results[1] as Either<Failure, List<GetOrganisationsModel>>;
  final managedResult = results[2] as Either<Failure, List<GetMyOrganisationModel>>;
  final publicResult = results[3] as Either<Failure, List<GetOrganisationsModel>>;

  // 3. You can check for failures here. 
  // For simplicity, we'll extract the success values or use empty lists
  List<GetOrganisationsModel> joined = [];
  List<GetMyOrganisationModel> managed = [];
  List<GetOrganisationsModel> public = [];

  joinedResult.fold((_) => null, (success) => joined = success);
  managedResult.fold((_) => null, (success) => managed = success);
  publicResult.fold((_) => null, (success) => public = success);

  // 4. Emit one single state with everything populated
  emit(OrgLoaded(
    organisations: joined,
    myOrganisations: managed,
    publicOrganisations: public,
    activeOrgId: activeId,
    // Preserve other fields like single 'organisation' if it exists
    organisation: currentState is OrgLoaded ? currentState.organisation : null,
  ));
}
}

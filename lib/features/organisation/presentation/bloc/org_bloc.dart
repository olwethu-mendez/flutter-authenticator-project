import 'dart:async';

import 'package:authentipass/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authentipass/features/auth/presentation/bloc/auth_event.dart';
import 'package:authentipass/features/organisation/domain/repository/organisation_repository.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_event.dart';
import 'package:authentipass/features/organisation/presentation/bloc/org_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrgBloc extends Bloc<OrgEvent, OrgState> {
  final OrganisationRepository repository;
  final AuthLocalDataSource localDataSource;
  final AuthBloc authBloc;

  OrgBloc({required this.repository, required this.localDataSource, required this.authBloc}) : super(OrgInitial()){
    on<CreateOrganisationsRequested>(_onCreateOrganisation);
    on<GetMyOrganisationsRequested>(_onGetMyOrganisations);
    on<GetPublicOrganisationsRequested>(_onGetPublicOrganisations);
    on<GetOrganisationRequested>(_onGetOrganisation);
    on<AcceptInvitationRequested>(_onAcceptInvitation);
    on<InviteUserToOrganisationRequested>(_onInviteUserToOrganisatio);
    on<SwitchOrganisationRequested>(_onSwitchOrganisation);
  }

  Future<void> _onCreateOrganisation(CreateOrganisationsRequested event, Emitter<OrgState> emit) async {
    emit(OrgLoading());
    final result = await repository.createOrganisation(event.createOrganisationModel);

    await result.fold(
      (failure) async => emit(OrgError(failure.message)),
      (success) async {
        
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

  Future<void> _onGetMyOrganisations(GetMyOrganisationsRequested event, Emitter<OrgState> emit) async {
    final currentState = state;
    emit(OrgLoading());
    final activeId = await localDataSource.getActiveOrgId();
    final result = await repository.getMyOrganisations();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(OrgLoaded(
      myOrganisations: success,
      // PRESERVE existing my organisations if they exist
      organisation: currentState is OrgLoaded ? currentState.organisation : null,
      publicOrganisations: currentState is OrgLoaded ? currentState.publicOrganisations : null,
      activeOrgId: activeId,
    )),
    );
  }

  Future<void> _onGetPublicOrganisations(GetPublicOrganisationsRequested event, Emitter<OrgState> emit) async {
    final currentState = state;
    emit(OrgLoading());
    final activeId = await localDataSource.getActiveOrgId();
    final result = await repository.getPublicOrganisations();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(OrgLoaded(
      publicOrganisations: success,
      // PRESERVE existing my organisations if they exist
      organisation: currentState is OrgLoaded ? currentState.organisation : null,
      myOrganisations: currentState is OrgLoaded ? currentState.myOrganisations : null,
      activeOrgId: activeId,
    )),);
  }

  Future<void> _onGetOrganisation(GetOrganisationRequested event, Emitter<OrgState> emit) async {
    final currentState = state;
    emit(OrgLoading());
    final result = await repository.getOrganisation(event.organisationId);
    final activeId = await localDataSource.getActiveOrgId();

    result.fold(
      (failure) => emit(OrgError(failure.message)),
      (success) => emit(OrgLoaded(
      organisation: success,
      // PRESERVE existing my organisations if they exist
      myOrganisations: currentState is OrgLoaded ? currentState.myOrganisations : null,
      publicOrganisations: currentState is OrgLoaded ? currentState.publicOrganisations : null,
      activeOrgId: activeId,
    )),);
  }

  Future<void> _onAcceptInvitation(AcceptInvitationRequested event, Emitter<OrgState> emit) async {
    emit(OrgLoading());
    final result = await repository.acceptInvitation(event.organisationId, event.invitationAccepted);

    await result.fold(
      (failure) async => emit(OrgError(failure.message)),
      (success) async {
        
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

  Future<void> _onInviteUserToOrganisatio(InviteUserToOrganisationRequested event, Emitter<OrgState> emit) async {
    final currentState = state;
    final result = await repository.inviteUserToOrganisation(event.profileId);

    await result.fold(
      (failure) async => emit(OrgError(failure.message)),
      (success) async {
      // Success! Keep the current list, but maybe show a snackbar (via BlocListener in UI)
      if (currentState is OrgLoaded) {
        emit(currentState); 
      }
      add(GetMyOrganisationsRequested()); // Refresh the lists
    });
  }

  Future<void> _onSwitchOrganisation(SwitchOrganisationRequested event, Emitter<OrgState> emit) async {
    emit(OrgLoading());
    final result = await repository.switchOrganisation(event.organisationId);

    await result.fold(
      (failure) async => emit(OrgError(failure.message)),
      (success) async {
        
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
}
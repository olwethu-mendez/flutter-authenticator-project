import 'package:authentipass/features/organisation/data/models/get_my_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisations_model.dart';
import 'package:authentipass/features/users_management/data/models/users_filtered_list_model.dart';
import 'package:equatable/equatable.dart';

abstract class OrgState extends Equatable {
  const OrgState();
  @override
  List<Object?> get props => [];
}

class OrgInitial extends OrgState {}
class OrgLoading extends OrgState {}
class OrgLoaded extends OrgState {
  final List<GetMyOrganisationModel>? myOrganisations;
  final List<UsersFilteredListModel>? invitableUsers;
  final List<GetOrganisationsModel>? organisations;
  final List<GetOrganisationsModel>? publicOrganisations;
  final GetOrganisationModel? organisation;
  final String? activeOrgId;
  const OrgLoaded({
    this.myOrganisations,
    this.publicOrganisations,
    this.invitableUsers,
    this.organisations,
    this.organisation,
    this.activeOrgId
  });OrgLoaded copyWith({
    List<GetOrganisationsModel>? organisations,
    List<UsersFilteredListModel>? invitableUsers,
    List<GetMyOrganisationModel>? myOrganisations,
    List<GetOrganisationsModel>? publicOrganisations,
    GetOrganisationModel? organisation,
    String? activeOrgId,
  }) {
    return OrgLoaded(
      organisations: organisations ?? this.organisations,
      myOrganisations: myOrganisations ?? this.myOrganisations,
      publicOrganisations: publicOrganisations ?? this.publicOrganisations,
      activeOrgId: activeOrgId ?? this.activeOrgId,
      invitableUsers: invitableUsers ?? this.invitableUsers,
      organisation: organisation ?? this.organisation,
    );
  }

  @override
  List<Object?> get props => [myOrganisations, publicOrganisations, organisations, organisation, invitableUsers, activeOrgId];
}
class OrgError extends OrgState {
  final String message;
  const OrgError(this.message);
}
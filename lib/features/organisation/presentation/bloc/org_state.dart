import 'package:authentipass/features/organisation/data/models/get_my_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisations_model.dart';
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
  final List<GetOrganisationsModel>? publicOrganisations;
  final GetOrganisationModel? organisation;
  final String? activeOrgId;
  const OrgLoaded({
    this.myOrganisations,
    this.publicOrganisations,
    this.organisation,
    this.activeOrgId
  });

  @override
  List<Object?> get props => [myOrganisations, publicOrganisations, organisation, activeOrgId];
}
class OrgError extends OrgState {
  final String message;
  const OrgError(this.message);
}
import 'package:authentipass/features/organisation/data/models/create_organisation_model.dart';
import 'package:equatable/equatable.dart';

abstract class OrgEvent extends Equatable {
  const OrgEvent();
  @override
  List<Object?> get props => [];
}

class GetMyOrganisationsRequested extends OrgEvent {}

class GetPublicOrganisationsRequested extends OrgEvent {}

class GetOrganisationRequested extends OrgEvent {
  final String organisationId;
  const GetOrganisationRequested(this.organisationId);
}

class CreateOrganisationsRequested extends OrgEvent {
  final CreateOrganisationModel createOrganisationModel;
  const CreateOrganisationsRequested(this.createOrganisationModel);
}

class InviteUserToOrganisationRequested extends OrgEvent {
  final String profileId;
  const InviteUserToOrganisationRequested(this.profileId);
}

class AcceptInvitationRequested extends OrgEvent {
  final String organisationId;
  final bool invitationAccepted;
  const AcceptInvitationRequested(this.organisationId, this.invitationAccepted);
}

class SwitchOrganisationRequested extends OrgEvent {
  final String organisationId;
  const SwitchOrganisationRequested(this.organisationId);
}

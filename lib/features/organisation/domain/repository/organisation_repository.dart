import 'package:authentipass/core/error/failures.dart';
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/organisation/data/models/create_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_my_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisations_model.dart';
import 'package:dartz/dartz.dart';

abstract class OrganisationRepository {
  Future<Either<Failure,AuthResultsModel>> createOrganisation(CreateOrganisationModel createOrganisation);
  Future<Either<Failure,void>> inviteUserToOrganisation(String profileId);
  Future<Either<Failure,AuthResultsModel>> acceptInvitation(String organisationId, bool invitationAccepted);
  Future<Either<Failure,List<GetMyOrganisationModel>>> getMyOrganisations();
  Future<Either<Failure,List<GetOrganisationsModel>>> getPublicOrganisations();
  Future<Either<Failure,GetOrganisationModel>> getOrganisation(String organisationId);
  Future<Either<Failure,AuthResultsModel>> switchOrganisation(String organisationId);
}
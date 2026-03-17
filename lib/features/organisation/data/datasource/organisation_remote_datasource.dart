import 'package:authentipass/core/error/exceptions.dart';
import 'package:authentipass/features/auth/data/models/auth_results_model.dart';
import 'package:authentipass/features/organisation/data/models/create_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_my_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisation_model.dart';
import 'package:authentipass/features/organisation/data/models/get_organisations_model.dart';
import 'package:dio/dio.dart';

abstract class OrganisationRemoteDataSource {
  Future<AuthResultsModel> createOrganisation(CreateOrganisationModel createOrganisation);
  Future<void> inviteUserToOrganisation(String profileId);
  Future<AuthResultsModel> acceptInvitation(String organisationId, bool invitationAccepted);
  Future<List<GetMyOrganisationModel>> getMyOrganisations();
  Future<List<GetOrganisationsModel>> getPublicOrganisations();
  Future<GetOrganisationModel> getOrganisation(String organisationId);
  Future<AuthResultsModel> switchOrganisation(String organisationId);
}

class OrganisationRemoteDataSourceImpl implements OrganisationRemoteDataSource {
  final Dio dio;

  OrganisationRemoteDataSourceImpl({required this.dio});
  // Inside OrganisationRemoteDataSourceImpl
  void _handleError(DioException e) {
    // Check if our Interceptor already put a custom exception in the 'error' field
    if (e.error is InvalidRequestException) {
      throw e.error as InvalidRequestException;
    }
    if (e.error is InvalidCredentialsExceptions) {
      throw e.error as InvalidCredentialsExceptions;
    }

    // Fallback: If Interceptor didn't catch it, try to parse the raw response
    String message = "An unexpected error occurred";
    if (e.response?.data != null && e.response?.data is Map) {
      message = e.response?.data['error'] ?? message;
    }

    if (e.response?.statusCode == 400) {
      throw InvalidRequestException(message);
    } else {
      throw ServerException(message);
    }
  }

  // Inside OrganisationRemoteDataSourceImpl  
  @override
  Future<List<GetMyOrganisationModel>> getMyOrganisations() async {
    try {
      final res = await dio.get('/organisation/my-organisations');
      final List<dynamic> data = res.data;
      return data.map((json) => GetMyOrganisationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  @override
  Future<GetOrganisationModel> getOrganisation(String organisationId) async {
    try {
      final res = await dio.get('/organisation/get-organisation/$organisationId');
      return GetOrganisationModel.fromJson(res.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  @override
  Future<List<GetOrganisationsModel>> getPublicOrganisations() async {
    try {
      final res = await dio.get('/organisation/public-organisations');
      final List<dynamic> data = res.data;
      return data.map((json) => GetOrganisationsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  @override
  Future<AuthResultsModel> switchOrganisation(String organisationId) async {
    try {
      final res = await dio.post('/organisation/switch-organisation/$organisationId');
      return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;      
    }
  }
  
  @override
  Future<AuthResultsModel> acceptInvitation(String organisationId, bool invitationAccepted) async {
    try {
      final res = await dio.put('/organisation/accept-invitation?organisationId=$organisationId&invitationAccepted=$invitationAccepted');
      return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;      
    }
    
  }
  
  @override
  Future<AuthResultsModel> createOrganisation(CreateOrganisationModel createOrganisation) async {
    try {// Create FormData for Multipart upload
      final formData = FormData.fromMap({
        'Name': createOrganisation.name,
        'Description': createOrganisation.description,
        'IsPublic': createOrganisation.isPublic,
        if (createOrganisation.organizationImage != null)
          'OrganizationImage': await MultipartFile.fromFile(createOrganisation.organizationImage!.path),
        if (createOrganisation.organizationHeaderImage != null)
          'OrganizationHeaderImage': await MultipartFile.fromFile(createOrganisation.organizationHeaderImage!.path),
      });
      final res = await dio.post('/organisation/create', data: formData);
      return AuthResultsModel.fromJson(res.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;      
    }
  }
  
  @override
  Future<void> inviteUserToOrganisation(String profileId) async {
    try {
      await dio.post('/organisation/invitation?profileId=$profileId');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;      
    }
  }
}
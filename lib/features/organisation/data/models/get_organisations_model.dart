import 'package:equatable/equatable.dart';

class GetOrganisationsModel extends Equatable
{

  const GetOrganisationsModel({required this.organizationId, required this.name, required this.subdomain, required this.isPublic, required this.isAdmin, required this.invitationAccepted, required this.organizationImageUrl, required this.status});
    final String? organizationId;
    final String? name;
    final String? subdomain;
    final bool? isPublic;
    final bool? isAdmin;
    final bool? invitationAccepted;
    final String? organizationImageUrl;
    final String? status;
    
      @override
      List<Object?> get props => [organizationId, name, subdomain, isPublic, organizationImageUrl, status];

  factory GetOrganisationsModel.fromJson(Map<String, dynamic> json) {
    return GetOrganisationsModel(
      organizationId: json['organizationId'] as String?,
      name: json['name'] as String?,
      subdomain: json['subdomain'] as String?,
      isPublic: json['isPublic'] as bool?,
      isAdmin: json['isAdmin'] as bool?,
      invitationAccepted: json['invitationAccepted'] as bool?,
      organizationImageUrl: json['organizationImageUrl'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, String?> toJson() {
    return {
      'organizationId': organizationId,
      'name': name,
      'subdomain': subdomain,
      'isAdmin': isAdmin.toString(),
      'invitationAccepted': invitationAccepted.toString(),
      'isPublic': isPublic.toString(),
      'organizationImageUrl': organizationImageUrl,
      'status': status,
    };
  }
}
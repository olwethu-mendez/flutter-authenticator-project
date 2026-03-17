import 'package:equatable/equatable.dart';

class GetMyOrganisationModel extends Equatable
{

  const GetMyOrganisationModel({required this.organizationId, required this.name, required this.subdomain, required this.isPublic, required this.organizationImageUrl, required this.isAdmin, required this.status});
    final String? organizationId;
    final String? name;
    final String? subdomain;
    final bool? isPublic;
    final bool? isAdmin;
    final String? organizationImageUrl;
    final String? status;
    
      @override
      List<Object?> get props => [organizationId, name, subdomain, isPublic, organizationImageUrl, isAdmin, status];

  factory GetMyOrganisationModel.fromJson(Map<String, dynamic> json) {
    return GetMyOrganisationModel(
      organizationId: json['organizationId'] as String?,
      name: json['name'] as String?,
      subdomain: json['subdomain'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      organizationImageUrl: json['organizationImageUrl'] as String?,
      status: json['status']?.toString(),
    );
  }

  Map<String, String?> toJson() {
    return {
      'organizationId': organizationId,
      'name': name,
      'subdomain': subdomain,
      'isPublic': isPublic.toString(),
      'isAdmin': isAdmin.toString(),
      'organizationImageUrl': organizationImageUrl,
      'status': status,
    };
  }
}
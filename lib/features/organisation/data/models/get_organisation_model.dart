import 'package:equatable/equatable.dart';

class GetOrganisationModel extends Equatable {
  const GetOrganisationModel({
    required this.organizationId,
    required this.name,
    required this.description,
    required this.subdomain,
    required this.isPublic,
    required this.organizationImageUrl,
    required this.organizationHeaderImageUrl,
    required this.status,
    required this.isAdmin,
    required this.invitationAccepted,
  });
  final String? organizationId;
  final String? name;
  final String? description;
  final String? subdomain;
  final bool? isPublic;
  final bool? isAdmin;
  final bool? invitationAccepted;
  final String? organizationImageUrl;
  final String? organizationHeaderImageUrl;
  final String? status;
  @override
  List<Object?> get props => [
    organizationId,
    name,
    description,
    subdomain,
    isPublic,
    organizationImageUrl,
    organizationHeaderImageUrl,
    status,
  ];

  factory GetOrganisationModel.fromJson(Map<String, dynamic> json) {
    return GetOrganisationModel(
      organizationId: json['organizationId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      subdomain: json['subdomain'] as String?,
      isPublic: json['isPublic'] as bool?,
      isAdmin: json['isAdmin'] as bool?,
      invitationAccepted: json['invitationAccepted'] as bool?,
      organizationImageUrl: json['organizationImageUrl'] as String?,
      organizationHeaderImageUrl: json['organizationHeaderImageUrl'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, String?> toJson() {
    return {
      'organizationId': organizationId,
      'name': name,
      'description': description,
      'subdomain': subdomain,
      'isAdmin': isAdmin.toString(),
      'invitationAccepted': invitationAccepted.toString(),
      'isPublic': isPublic.toString(),
      'organizationImageUrl': organizationImageUrl,
      'organizationHeaderImageUrl': organizationHeaderImageUrl,
      'status': status,
    };
  }
}

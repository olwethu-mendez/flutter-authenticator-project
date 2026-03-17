import 'dart:io';

import 'package:equatable/equatable.dart';

class CreateOrganisationModel extends Equatable {
  const CreateOrganisationModel({
    required this.name,
    required this.description,
    //required this.subdomain,
    required this.isPublic,
    required this.organizationImage,
    required this.organizationHeaderImage,
  });
  final String? name;
  final String? description;
  //final String? subdomain;
  final bool? isPublic;
  final File? organizationImage;
  final File? organizationHeaderImage;

  @override
  List<Object?> get props => [
    name,
    description,
    isPublic,
    organizationImage,
    organizationHeaderImage,
  ];

  Map<String, String?> toMap() {
    return {
      'name': name,
      'description': description,
      'isPublic': isPublic.toString(),
    };
  }
}

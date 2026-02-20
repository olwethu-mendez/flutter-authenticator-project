class DeactivateAccountModel {
  final String password;

  DeactivateAccountModel({
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'password': password,
  };
}
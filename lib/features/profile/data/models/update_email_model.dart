class UpdateEmailModel {
  final String password;
  final String newEmail;

  UpdateEmailModel({
    required this.password,
    required this.newEmail,
  });

  Map<String, dynamic> toJson() => {
    'password': password,
    'newEmail': newEmail,
  };
}
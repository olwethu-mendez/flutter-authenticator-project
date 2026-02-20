class UpdatePhoneNumberModel {
  final String password;
  final String countryCode;
  final String newPhoneNumber;

  UpdatePhoneNumberModel({
    required this.password,
    required this.countryCode,
    required this.newPhoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'password': password,
    'countryCode': countryCode,
    'newPhoneNumber': newPhoneNumber,
  };
}
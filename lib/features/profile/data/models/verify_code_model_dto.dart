class VerifyCodeModelDto {
  final String type;
  final String code;

  VerifyCodeModelDto({
    required this.type,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'code': code,
  };
}
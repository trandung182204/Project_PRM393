class ResetPasswordRequest {
  final String phoneNumber;
  final String otpCode;
  final String newPassword;

  ResetPasswordRequest({
    required this.phoneNumber,
    required this.otpCode,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'otpCode': otpCode,
    'newPassword': newPassword,
  };
}

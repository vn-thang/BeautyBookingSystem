class TokenResponseModel {
  final String accessToken;
  final String refreshToken;

  TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend trả về ApiResponse<TokenResponse> hoặc TokenResponse trực tiếp.
    // Nếu backend trả ApiResponse<TokenResponse>.Ok(...), hãy lấy field phù hợp.
    // Ví dụ backend Register trả TokenResponse trực tiếp (theo code bạn gửi là Register trả TokenResponse).
    final data = json.containsKey('data') ? json['data'] : json;
    return TokenResponseModel(
      accessToken: data['accessToken'] ?? data['access_token'] ?? '',
      refreshToken: data['refreshToken'] ?? data['refresh_token'] ?? '',
    );
  }
}
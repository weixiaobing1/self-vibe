class User {
  final int id;
  final String username;
  final String? nickname;
  final String? avatar;
  final String? email;
  final String? aiModel;
  final String? studyTarget;

  User({
    required this.id,
    required this.username,
    this.nickname,
    this.avatar,
    this.email,
    this.aiModel,
    this.studyTarget,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nickname: json['nickname'],
      avatar: json['avatar'],
      email: json['email'],
      aiModel: json['aiModel'],
      studyTarget: json['studyTarget'],
    );
  }
}

class LoginResult {
  final String accessToken;
  final String refreshToken;
  final User user;

  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: User.fromJson(json['userInfo'] ?? {}),
    );
  }
}
class UserDM {
  static const collectionName = "users";
  static UserDM? currentUser;
  String id;
  String email;
  String userName;

  UserDM({
    required this.id,
    required this.email,
    required this.userName,
  });

  UserDM.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        userName = json['userName'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userName': userName,
    };
  }
}

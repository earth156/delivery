
class UserLogin {
  int userId;
  String name;
  String phone;
  String type;

  UserLogin({
    required this.userId,
    required this.name,
    required this.phone,
    required this.type,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
        userId: json["user_id"],  // ตรวจสอบให้แน่ใจว่าค่านี้เป็น int
        name: json["name"],
        phone: json["phone"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "phone": phone,
        "type": type,
      };
}

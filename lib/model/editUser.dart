class EditUser {
  int userId;
  String username;
  String password; // แก้ไขจาก 'passward' เป็น 'password'
  String email;
  String phone;
  String img;
  String types;
  String money; // เพิ่มฟิลด์ money เป็น String

  EditUser({
    required this.userId,
    required this.username,
    required this.password,
    required this.email,
    required this.phone,
    required this.img,
    required this.types,
    required this.money, // เพิ่มใน constructor
  });

  EditUser copyWith({
    int? userId,
    String? username,
    String? password,
    String? email,
    String? phone,
    String? img,
    String? types,
    String? money, // เพิ่มใน copyWith
  }) =>
      EditUser(
        userId: userId ?? this.userId,
        username: username ?? this.username,
        password: password ?? this.password,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        img: img ?? this.img,
        types: types ?? this.types,
        money: money ?? this.money, // ใช้ค่าเริ่มต้นถ้าไม่ได้ส่งมา
      );

  factory EditUser.fromJson(Map<String, dynamic> json) => EditUser(
    userId: json["user_id"] ?? 0, // ตรวจสอบค่าเริ่มต้น
    username: json["username"] ?? '', // ตรวจสอบค่าเริ่มต้น
    password: json["password"] ?? '', // ตรวจสอบค่าเริ่มต้น
    email: json["email"] ?? '', // ตรวจสอบค่าเริ่มต้น
    phone: json["phone"] ?? '', // ตรวจสอบค่าเริ่มต้น
    img: json["img"] ?? '', // ตรวจสอบค่าเริ่มต้น
    types: json["types"] ?? '', // ตรวจสอบค่าเริ่มต้น
    money: json["money"] ?? '0', // ตรวจสอบค่าเริ่มต้น (ค่า default เป็น '0')
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "password": password, // แก้ไขจาก 'passward' เป็น 'password'
    "email": email,
    "phone": phone,
    "img": img,
    "types": types,
    "money": money, // เพิ่ม money ใน toJson
  };
}

class ShowUser {
  int userId;
  String name;
  String phone;
  String password;
  dynamic carReg; // carReg อาจจะเป็น null ก็ได้
  String profile;
  String address;
  String gps;
  String type;

  ShowUser({
    required this.userId,
    required this.name,
    required this.phone,
    required this.password,
    required this.carReg,
    required this.profile,
    required this.address,
    required this.gps,
    required this.type,
  });

  factory ShowUser.fromJson(Map<String, dynamic> json) => ShowUser(
    userId: json["user_id"] ?? 0, // หาก null ให้ใช้ค่าเริ่มต้นเป็น 0
    name: json["name"] ?? '', // หาก null ให้ใช้ค่าเริ่มต้นเป็น String ว่าง
    phone: json["phone"] ?? '', // หาก null ให้ใช้ค่าเริ่มต้นเป็น String ว่าง
    password: json["password"] ?? '', // หาก null ให้ใช้ค่าเริ่มต้นเป็น String ว่าง
    carReg: json["car_reg"], // carReg ยังคงเป็น dynamic และอาจเป็น null ได้
    profile: json["profile"] ?? '', // หาก null ให้ใช้ค่าเริ่มต้นเป็น String ว่าง
    address: json["address"] ?? '', // หาก null ให้ใช้ค่าเริ่มต้นเป็น String ว่าง
    gps: json["gps"] ?? '', // หาก null ให้ใช้ค่าเริ่มต้นเป็น String ว่าง
    type: json["type"] ?? '', // หาก null ให้ใช้ค่าเริ่มต้นเป็น String ว่าง
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "phone": phone,
    "password": password,
    "car_reg": carReg,
    "profile": profile,
    "address": address,
    "gps": gps,
    "type": type,
  };
}

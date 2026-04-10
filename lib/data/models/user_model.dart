class UserModel {
  final String shopId;
  final String name;
  final String email;

  UserModel({
    required this.shopId,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_id': shopId,
      'name': name,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      shopId: map['shop_id'],
      name: map['name'],
      email: map['email'],
    );
  }
}
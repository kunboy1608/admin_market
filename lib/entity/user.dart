import 'package:admin_market/entity/entity.dart';

class User extends Entity {
  String? address;
  String? phoneNumber;
  String? fullName;
  String? userId;

  User();

  User.fromMap(Map<String, dynamic> map) {
    address = map["address"];
    phoneNumber = map["phone_number"];
    fullName = map["full_name"];
    userId = map["user_id"];

    uploadDate = map["upload_date"];
    lastUpdatedDate = map["last_update_date"];
    id = map["id"];
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'address': address,
        'phone_number': phoneNumber,
        'full_name': fullName,
        'user_id': userId
      });
  }
}

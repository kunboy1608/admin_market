import 'package:admin_market/entity/entity.dart';

class Order extends Entity {
  String? userId;
  List<String>? vouchers;
  // Map<ProductId, Map<price, quantity>>
  Map<String, Map<String, int>>? products;

  // 0: Add to cart
  // 1: Waitting to confirm
  // 2: Waiting to delivery man take product
  // 3: Delivering
  // 4: Delivered
  // 5: Cancelled
  // 6: Refund
  int? status;

  Order() {
    status = 0;
  }

  Order.fromMap(Map<String, dynamic> map) {
    userId = map["user_id"];
    status = map["status"];

    products = {};
    map["products"]?.forEach((key, value) {
      products!.addAll({
        key: {
          value.keys.first.toString(): int.parse(value.values.first.toString())
        }
      });
    });

    vouchers = [];
    map["vouchers"]?.forEach((e) {
      vouchers!.add(e.toString());
    });

    uploadDate = map["upload_date"];
    lastUpdatedDate = map["last_update_date"];

    id = map["id"];
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'user_id': userId,
        'vouchers': vouchers,
        'products': products,
        'status': status
      });
  }
}

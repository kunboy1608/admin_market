import 'package:admin_market/entity/entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product extends Entity {
  // Basic attribute
  String? name;
  double? price;
  int? categoryId;
  String? imgUrl;
  String? provider;
  String? description;
  int? quantitySold;

  // Discount attribute
  Timestamp? startDiscountDate;
  Timestamp? endDiscountDate;
  double? discountPrice;

  // Transient field
  String? actuallyLink;

  Product();

  Product.fromMap(Map<String, dynamic> map) {
    name = map["name"];
    price = double.parse(map["price"].toString());
    categoryId = map["category_id"];
    imgUrl = map["img_url"];
    provider = map["provider"];
    description = map["description"];
    quantitySold = map["quantity_sold"];

    discountPrice = map["discount_price"];
    startDiscountDate = map["start_discount_date"];
    endDiscountDate = map["end_discount_date"];

    uploadDate = map["upload_date"];
    lastUpdatedDate = map["last_update_date"];

    id = map["id"];
    actuallyLink = map["actually_link"];
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'name': name,
        'price': price,
        'category_id': categoryId,
        'img_url': imgUrl,
        'provider': provider,
        'description': description,
        'quantity_sold': quantitySold,
        // Discount attribute
        'discount_price': discountPrice,
        'start_discount_date': startDiscountDate,
        'end_discount_date': endDiscountDate,
        // Transient field
        'actually_link': actuallyLink
      });
  }
}

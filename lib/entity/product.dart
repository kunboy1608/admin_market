import 'package:admin_market/entity/entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product extends Entity {
  static String get collectionName => "products";

  String? name;
  double? price;
  int? categoryId;
  String? imgUrl;
  String? provider;
  Timestamp? date;

  // Transient field
  String? id;
  String? actuallyLink;

  Product();

  Product.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    price = double.parse(map["price"].toString());
    categoryId = map["category_id"];
    imgUrl = map["img_url"];
    provider = map["provider"];
    date = map["date"];
    actuallyLink = map["actually_link"];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'img_url': imgUrl,
      'provider': provider,
      'date': date,
    };
  }
}

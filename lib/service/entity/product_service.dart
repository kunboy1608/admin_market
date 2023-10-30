import 'dart:async';

import 'package:admin_market/entity/product.dart';
import 'package:admin_market/service/entity/entity_service.dart';
import 'package:admin_market/service/google/firestore_service.dart';
import 'package:admin_market/service/image_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService extends EntityService<Product> {
  static final ProductService _instance = ProductService._();
  static ProductService get instance => _instance;
  ProductService._();

  @override
  String collectionName = "products";

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(Product e) async {
    return FirestoreService.instance.getFireStore().then((fs) => fs
        .collection(collectionName)
        .add(e.toMap()
          ..remove("id")
          ..remove("actually_link")
          ..addAll({
            'upload_date': Timestamp.now(),
            'last_update_date': Timestamp.now()
          })));
  }

  @override
  Future<List<Product>?> get() async {
    List<Product> list = await FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                return Product.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));

    for (int i = 0; i < list.length; i++) {
      if (list[i].imgUrl != null) {
        list[i].actuallyLink =
            await ImageService.instance.getActuallyLink(list[i].imgUrl!);
      }
    }

    return list;
  }

  @override
  Future<void> update(Product e) {
    return FirestoreService.instance.getFireStore().then((fs) {
      return fs.collection(collectionName).doc(e.id).update(e.toMap()
        ..remove("id")
        ..remove("actually_link")
        ..addAll({'last_update_date': Timestamp.now()}));
    });
  }

  @override
  Future<Product?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null) {
                if (value.data()!['img_url'] != null ||
                    value.data()!['img_url'].isNotEmpty) {
                  return ImageService.instance
                      .getActuallyLink(value.data()!['img_url'])
                      .then((link) {
                    return Product.fromMap(value.data()!)
                      ..actuallyLink = link
                      ..id = id;
                  });
                } else {
                  return Product.fromMap(value.data()!)..id = id;
                }
              }
              return null;
            }));
  }
}

import 'dart:async';

import 'package:admin_market/entity/order.dart';
import 'package:admin_market/service/entity/entity_service.dart';
import 'package:admin_market/service/google/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

class OrderAdminService extends EntityService<Order> {
  static final OrderAdminService _instance = OrderAdminService._();
  static OrderAdminService get instance => _instance;
  OrderAdminService._();

  @override
  String collectionName = "orders";

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(Order e) async {
    return FirestoreService.instance.getFireStore().then(
        (fs) => fs.collection(collectionName).add(e.toMap()..remove("id")));
  }

  @override
  Future<List<Order>?> get() async {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                return Order.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));
  }

  Future<void> forwardStep(Order e) async {
    if (e.status == null) {
      return;
    }
    e.status = (e.status! + 1).clamp(1, 4);

    return update(e);
  }

  Future<void> cancel(Order e) async {
    if (e.status == null) {
      return;
    }
    e.status = 5;

    return update(e);
  }

  Future<void> refund(Order e) async {
    if (e.status == null) {
      return;
    }
    e.status = 6;

    return update(e);
  }

  @override
  void listenChanges(StreamController<(DocumentChangeType, Order)> controller) {
    FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).snapshots().listen((event) {
              for (var element in event.docChanges) {
                Order p = Order.fromMap(element.doc.data()!)
                  ..id = element.doc.id;
                controller.sink.add((element.type, p));
              }
            }));
  }

  @override
  Future<Order?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null) {
                return Order.fromMap(value.data()!)..id = id;
              }
              return null;
            }));
  }
}

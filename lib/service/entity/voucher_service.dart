import 'dart:async';

import 'package:admin_market/entity/voucher.dart';
import 'package:admin_market/service/entity/entity_service.dart';
import 'package:admin_market/service/google/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherService extends EntityService<Voucher> {
  static final VoucherService _instance = VoucherService._();
  static VoucherService get instance => _instance;
  VoucherService._();

  @override
  String collectionName = "vouchers";

  @override
  Future<List<Voucher>?> get() {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                return Voucher.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));
  }

  @override
  void listenChanges(
      StreamController<(DocumentChangeType, Voucher)> controller) {
    FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).snapshots().listen((event) {
              for (var element in event.docChanges) {
                Voucher v = Voucher.fromMap(element.doc.data()!)
                  ..id = element.doc.id;
                controller.sink.add((element.type, v));
              }
            }));
  }

  @override
  Future<Voucher?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null) {
                return Voucher.fromMap(value.data()!)..id = id;
              }
              return null;
            }));
  }
}

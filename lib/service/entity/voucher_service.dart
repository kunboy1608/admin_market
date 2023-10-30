import 'dart:async';

import 'package:admin_market/entity/voucher.dart';
import 'package:admin_market/service/entity/entity_service.dart';
import 'package:admin_market/service/google/firestore_service.dart';

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

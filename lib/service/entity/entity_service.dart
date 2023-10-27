import 'dart:async';

import 'package:admin_market/entity/entity.dart';
import 'package:admin_market/service/google/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class EntityService<T extends Entity> {
  abstract String collectionName;

  Future<List<T>?> get();
  void listenChanges(StreamController<(DocumentChangeType, T)> controller);

  Future<DocumentReference<Map<String, dynamic>>> add(T e) {
    return FirestoreService.instance.getFireStore().then((fs) => fs
        .collection(collectionName)
        .add(e.toMap()
          ..remove("id")
          ..addAll({
            'upload_date': Timestamp.now(),
            'last_update_date': Timestamp.now()
          })));
  }

  Future<T?> getById(String id);

  Future<void> update(T e) {
    return FirestoreService.instance.getFireStore().then((fs) {
      return fs.collection(collectionName).doc(e.id).update(e.toMap()
        ..remove("id")
        ..remove("upload_date")
        ..addAll({'last_update_date': Timestamp.now()}));
    });
  }

  Future<void> delete(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).delete());
  }
}

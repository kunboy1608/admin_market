import 'dart:async';

import 'package:admin_market/entity/user.dart';
import 'package:admin_market/service/entity/entity_service.dart';
import 'package:admin_market/service/google/firestore_service.dart';

class UserService extends EntityService<User> {
  static final UserService _instance = UserService._();
  static UserService get instance => _instance;
  UserService._();

  @override
  String collectionName = "users";

  @override
  Future<List<User>?> get() {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                return User.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));
  }

  @override
  Future<User?> getById(String id) {
    return FirestoreService.instance.getFireStore().then((fs) => fs
            .collection(collectionName)
            .where('user_id', isEqualTo: id)
            .limit(1)
            .get()
            .then((event) {
          if (event.docs.isEmpty) {
            return null;
          }
          return event.docs
              .map((doc) => User.fromMap(doc.data())..id = doc.id)
              .toList()
              .first;
        }));
  }
}

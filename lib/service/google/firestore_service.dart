import 'dart:async';

import 'package:admin_market/service/google/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchronized/synchronized.dart';

class FirestoreService {
  static FirestoreService? _instance;

  FirebaseFirestore? _firestore;

  FirestoreService._();
  static final Lock _lock = Lock();

  static FirestoreService get instance {
    if (_instance == null) {
      _lock.synchronized(() {
        _instance ??= FirestoreService._();
      });
    }
    return _instance!;
  }

  Future<FirebaseFirestore> getFireStore() async {
    if (_firestore == null) {
      return FirebaseService.instance.initializeFirebase().then((value) {
        _lock.synchronized(() {
          _firestore ??= FirebaseFirestore.instanceFor(app: (value!));
        });
        return _firestore!;
      });
    }
    return _firestore!;
  }
}

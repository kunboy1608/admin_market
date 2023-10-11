import 'dart:io';

import 'package:admin_market/service/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestorageService {
  static FirestorageService? _instance;
  FirebaseStorage? _firebaseStorage;

  FirestorageService._();
  static final Lock _lock = Lock();

  static FirestorageService get instance {
    if (_instance == null) {
      _lock.synchronized(() {
        _instance ??= FirestorageService._();
      });
    }
    return _instance!;
  }

  Future<void> _initFirestorage() async {
    if (_firebaseStorage == null) {
      return FirebaseService.instance.initializeFirebase().then((value) {
        _lock.synchronized(() async {
          _firebaseStorage ??= FirebaseStorage.instanceFor(app: (value!));
        });
      });
    }
  }

  Future<TaskSnapshot> upload(String path) async {
    return _initFirestorage().then((_) {
      File file = File(path);
      return _firebaseStorage!
          .ref()
          .child("images/${path.substring(path.lastIndexOf("/") + 1)}")
          .putFile(file)
          .then((_) => _);
    });
  }

  Future<String?> getLinkDownload(String path) async {
    try {
      await _initFirestorage();
      return await _firebaseStorage!.ref().child(path).getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> delete(String path) async {
    try {
      await _initFirestorage();
      return await _firebaseStorage!.ref().child(path).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

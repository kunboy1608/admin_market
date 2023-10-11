import 'dart:async';

import 'package:admin_market/entity/entity.dart';
import 'package:admin_market/entity/product.dart';
import 'package:admin_market/service/firebase_service.dart';
import 'package:admin_market/service/firestorage_service.dart';
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

  Future<void> _initFireStore() async {
    if (_firestore == null) {
      return FirebaseService.instance.initializeFirebase().then((value) {
        _lock.synchronized(() async {
          _firestore ??= FirebaseFirestore.instanceFor(app: (value!));
        });
      });
    }
  }

  Future<List<Entity>?> get(String collectionName) async {
    List<Entity> list = await _initFireStore()
        .then((_) => _firestore!.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                if (collectionName == Product.collectionName) {
                  return Product.fromMap(doc.data())..id = doc.id;
                } else {
                  throw "Wrong collection name";
                }
              }).toList();
            }));
    if (collectionName == Product.collectionName) {
      for (int i = 0; i < list.length; i++) {
        final p = list[i] as Product;
        if (p.imgUrl != null) {
          p.actuallyLink =
              await FirestorageService.instance.getLinkDownload(p.imgUrl!);
        }
      }
    }
    return list;
  }

  Future<void> delete(String collectionName, String id) async {
    return _initFireStore()
        .then((_) => _firestore!.collection(collectionName).doc(id).delete());
  }

  Future<DocumentReference<Map<String, dynamic>>> add(Entity e) async {
    return _initFireStore().then((_) {
      if (e is Product) {
        return _firestore!.collection(Product.collectionName).add(e.toMap()
          ..remove("id")
          ..remove("actually_link"));
      }
      throw "Unknow error";
    });
  }

  Future<void> update(Entity e) async {
    return _initFireStore().then((_) {
      if (e is Product) {
        return _firestore!
            .collection(Product.collectionName)
            .doc(e.id)
            .update(e.toMap()
              ..remove("id")
              ..remove("actually_link"));
      }
      throw "Unknow error";
    });
  }

  void listenChanges(String collectionName,
      StreamController<(DocumentChangeType, Entity)> controller) {
    _initFireStore().then((_) =>
        _firestore!.collection(collectionName).snapshots().listen((event) {
          if (collectionName == Product.collectionName) {
            for (var element in event.docChanges) {
              controller.sink.add((
                element.type,
                Product.fromMap(element.doc.data()!)..id = element.doc.id
              ));
            }
          }
        }));
  }
}

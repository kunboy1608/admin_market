import 'dart:async';

import 'package:admin_market/entity/banner.dart';
import 'package:admin_market/service/entity/entity_service.dart';
import 'package:admin_market/service/google/firestore_service.dart';
import 'package:admin_market/service/image_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BannerService extends EntityService<Banner> {
  static final BannerService _instance = BannerService._();
  static BannerService get instance => _instance;
  BannerService._();

  @override
  String collectionName = "banners";

  @override
  Future<List<Banner>?> get() async {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                return Banner.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));
  }

  @override
  void listenChanges(
      StreamController<(DocumentChangeType, Banner)> controller) {
    FirestoreService.instance.getFireStore().then((fs) =>
        fs.collection(collectionName).snapshots().listen((event) {
          for (var element in event.docChanges) {
            Banner b = Banner.fromMap(element.doc.data()!)..id = element.doc.id;
            // Get actually link
            if (b.imgUrl != null &&
                element.type != DocumentChangeType.removed) {
              ImageService.instance.getActuallyLink(b.imgUrl!).then((value) {
                b.actuallyLink = value;
                controller.sink.add((element.type, b));
              });
            } else {
              controller.sink.add((element.type, b));
            }
          }
        }));
  }

  @override
  Future<Banner?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null) {
                if (value.data()!['img_url'] != null ||
                    value.data()!['img_url'].isNotEmpty) {
                  return ImageService.instance
                      .getActuallyLink(value.data()!['img_url'])
                      .then((link) {
                    return Banner.fromMap(value.data()!)
                      ..actuallyLink = link
                      ..id = id;
                  });
                } else {
                  return Banner.fromMap(value.data()!)..id = id;
                }
              }
              return null;
            }));
  }
}

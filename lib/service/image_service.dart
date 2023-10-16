import 'dart:io';

import 'package:admin_market/service/firestorage_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class ImageService {
  static ImageService? _instance;

  ImageService._();
  static final Lock _lock = Lock();

  static ImageService get instance {
    if (_instance == null) {
      _lock.synchronized(() {
        _instance ??= ImageService._();
      });
    }
    return _instance!;
  }

  Future<String?> getActuallyLink(String imgUrl) async {
    String fileName = imgUrl.substring(imgUrl.indexOf("/") + 1);
    return getTemporaryDirectory().then(
        (direc) => File("${direc.path}/$fileName").exists().then((exists) {              
              if (exists) {
                return "${direc.path}/$fileName";
              } else {
                return FirestorageService.instance
                    .getLinkDownload(imgUrl)
                    .then((link) {
                  if (link != null) {
                    return Dio()
                        .download(link, "${direc.path}/$fileName")
                        .then((_) => "${direc.path}/$fileName");
                  } else {
                    return null;
                  }
                });
              }
            }));
  }
}

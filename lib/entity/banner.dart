import 'package:admin_market/entity/entity.dart';

class Banner extends Entity {
  String? imgUrl;

  // Transient field
  String? actuallyLink;

  Banner();
  Banner.fromMap(Map<String, dynamic> map) {
    imgUrl = map["img_url"];

    uploadDate = map["upload_date"];
    lastUpdatedDate = map["last_update_date"];

    id = map["id"];
    actuallyLink = map["actually_link"];
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({'img_url': imgUrl, 'actually_link': actuallyLink});
  }
}

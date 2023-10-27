import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Entity {
  String? id;

  // History fileds
  Timestamp? uploadDate;
  Timestamp? lastUpdatedDate;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'upload_date': uploadDate,
      'last_update_date': lastUpdatedDate
    };
  }
}

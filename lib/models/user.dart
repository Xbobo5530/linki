import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linki/values/consts.dart';
import 'package:meta/meta.dart';

class User {
  String name, id, bio, imageUrl;
  int createdAt;
  bool isAdmin;
  User(
      {@required this.name,
      this.bio,
      this.imageUrl,
      this.createdAt,
      this.id,
      this.isAdmin});

  User.fromSnapshot(DocumentSnapshot document)
      : this.id = document.documentID,
        this.name = document[NAME_FIELD],
        this.bio = document[BIO_FIELD],
        this.createdAt = document[CREATED_AT_FIELD],
        this.isAdmin = document[IS_ADMIN_FIELD],
        this.imageUrl = document[IMAGE_URL_FIELD];
}

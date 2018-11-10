import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linki/values/consts.dart';
import 'package:meta/meta.dart';

class User {
  String name, id, bio, imageUrl;
  int createdAt;
  User({@required this.name, this.bio, this.imageUrl, this.createdAt, this.id});

  User.fromSnapshot(DocumentSnapshot document)
  : this.id = document.documentID,
  this.name = document[NAME_FIELD],
  this.bio = document[BIO_FIELD],
  this.createdAt = document[CREATED_AT_FIELD],
  this.imageUrl = document[IMAGE_URL_FIELD];

}
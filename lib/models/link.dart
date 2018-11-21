import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linki/values/consts.dart';
import 'package:meta/meta.dart';

class Link {
  String id, url, title, imageUrl, description, createdBy;
  int createdAt, reports;

  Link(
      {this.id,
      @required this.url,
      @required this.title,
      this.imageUrl,
      this.description,
      this.reports,
      @required this.createdAt,
      this.createdBy})
      : assert(url != null),
        assert(title != null),
        assert(createdAt != null);

  /// a constructor for converting the snapshot to a dart object
  Link.fromSnapshot(DocumentSnapshot document)
      : this.id = document.documentID,
        this.url = document[URL_FIELD],
        this.title = document[TITLE_FIELD],
        this.imageUrl = document[IMAGE_URL_FIELD],
        this.description = document[DESCRIPTION_FIELD],
        this.reports = document[REPORTS_FIELD],
        this.createdAt = document[CREATED_AT_FIELD],
        this.createdBy = document[CREATED_BY_FIELD];
}

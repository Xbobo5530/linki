import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linki/src/values/consts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:meta/meta.dart';

class Link {
  String id,
      url,
      title,
      decodedTitle,
      imageUrl,
      description,
      decodedDescription,
      createdBy;
  int createdAt, reports, type;

  Link(
      {this.id,
      this.type,
      @required this.url,
      @required this.title,
      this.decodedTitle,
      this.imageUrl,
      this.description,
      this.decodedDescription,
      this.reports,
      @required this.createdAt,
      this.createdBy})
      : assert(url != null),
        assert(title != null),
        assert(createdAt != null);

  /// a constructor for converting the snapshot to a dart object
  Link.fromSnapshot(DocumentSnapshot document)
      : this.id = document.documentID,
        this.type = document[TYPE_FIELD],
        this.url = document[URL_FIELD],
        this.title = document[TITLE_FIELD],
        this.imageUrl = document[IMAGE_URL_FIELD],
        this.description = document[DESCRIPTION_FIELD],
        this.reports = document[REPORTS_FIELD],
        this.createdAt = document[CREATED_AT_FIELD],
        this.createdBy = document[CREATED_BY_FIELD];

  // @override
  // String toString() => '''
  //       id: ${this.id}
  //       type: ${this.type}
  //       url: ${this.url}
  //       title: ${this.title}
  //       decodedTitle: ${this.decodedTitle}
  //       imageUrl: ${this.imageUrl}
  //       description: ${this.description}
  //       decodedDescription: ${this.decodedDescription}
  //       reports: ${this.reports}
  //       createdAt: ${DateTime.fromMicrosecondsSinceEpoch(this.createdAt).toIso8601String()}
  //       createdBy: ${this.createdBy}
  //       ''';

  var unescape = HtmlUnescape();
  String decodeString(String text) {
    return unescape.convert(text);
  }
}

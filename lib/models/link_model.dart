import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:linki/models/link.dart';
import 'package:linki/models/user.dart';
import 'package:linki/values/consts.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

const _tag = 'LinkModel:';

abstract class LinkModel extends Model {
  final _database = Firestore.instance;

  Stream<QuerySnapshot> get linksStream =>
      _database.collection(LINKS_COLLECTION).snapshots();

  StatusCode _submittingLinkStatus;
  StatusCode get submittingLinkStatus => _submittingLinkStatus;
  StatusCode _deletingLinkStatus;
  StatusCode get deletingLinkStatus => _deletingLinkStatus;

  Map<String, Link> _links = Map();
  Map<String, Link> get links => _links;

  LinkiError _linkiErrorType;
  LinkiError get linkiError => _linkiErrorType;

  Future<StatusCode> getLinks() async {
    print('$_tag at getLinks');
    bool _hasError = false;
    QuerySnapshot snapshot = await _database
        .collection(LINKS_COLLECTION)
        .getDocuments()
        .catchError((error) {
      print('$_tag error on getting documents');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    List<DocumentSnapshot> documents = snapshot.documents;
    Map<String, Link> tempList = Map();
    documents.forEach((document) {
      Link link = Link.fromSnapshot(document);
      tempList.putIfAbsent(document.documentID, () => link);
    });

    _links = tempList;
    notifyListeners();
    return StatusCode.success;
  }

  // final List<String> validUrls= [
  //   WHATSAPP_DOT_COM
  // ];

  Future<StatusCode> submitLink(String url, User user) async {
    print('$_tag at submitLink');
    _submittingLinkStatus = StatusCode.waiting;
    notifyListeners();
    if (!url.contains(WHATSAPP_URL_SCHEME)) {
      _linkiErrorType = LinkiError.invalidUrlScheme;
      _submittingLinkStatus = StatusCode.failed;
      notifyListeners();
      return _submittingLinkStatus;
    }
    _submittingLinkStatus = await _processLink(url, user);
    notifyListeners();
    return _submittingLinkStatus;
  }

  Future<StatusCode> _processLink(String url, User user) async {
    print('$_tag at process link');
    bool _hasError = false;
    Response response =
        await http.get(url, headers: {'title': 'title'}).catchError((error) {
      print('$_tag error on downloading page');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;

    final titleTag = '<meta property="og:title" content="';
    final imageUrlTag = '<meta property="og:image" content="';
    final descriptionTag = '<meta property="og:description" content="';

    final title = _getValueFrom(response, titleTag);
    final imageUrl = _getValueFrom(response, imageUrlTag);
    final description = _getValueFrom(response, descriptionTag);

    return await _addLink(url, title, imageUrl, description, user);
  }

  String _getValueFrom(Response response, String tag) {
    print('$_tag at _getValueFrom');
    final body = response.body;
    //var titleTag = format; //'<meta property="og:title" content="';
    final tagLength = tag.length;
    final tagStartPos = body.indexOf(tag) + tagLength;
    final tagEndPos = body.indexOf('"', tagStartPos);
    return body.substring(tagStartPos, tagEndPos);
  }

  Future<StatusCode> _addLink(
      String url, title, imageUrl, description, User user) async {
    print('$_tag at _addLink');
    bool _hasError = false;
    final linkMap = {
      URL_FIELD: url,
      CREATED_BY_FIELD: user.id,
      TITLE_FIELD: title,
      IMAGE_URL_FIELD: imageUrl,
      DESCRIPTION_FIELD: description,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch
    };
    await _database
        .collection(LINKS_COLLECTION)
        .add(linkMap)
        .catchError((error) {
      print('$_tag there was an error: $error');
      _hasError = true;
    });

    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<StatusCode> deleteLink(String linkId) async {
    print('$_tag at deleteLink');
    bool _hasError = false;
    await Firestore.instance
        .collection(LINKS_COLLECTION)
        .document(linkId)
        .delete()
        .catchError((error) {
      print('$_tag error on deleting link document');
      _hasError = true;
    });

    if (_hasError) {
      _deletingLinkStatus = StatusCode.failed;
      notifyListeners();
      return _deletingLinkStatus;
    }
    _links.remove(linkId);

    _deletingLinkStatus = StatusCode.success;
    notifyListeners();
    return _deletingLinkStatus;
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  initiateContact() async {
    final url = CONTACT_URL;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  share(Link link) {
    final _shareText = '${link.title}\n${link.url}\nshared from Linki app: $LINKI_DOWNLOAD_URL';
    Share.share(_shareText);
  }
  report(Link link){
    //TODO: handle report link
    /// if a link has been reported more than 3 times, the link is automatically deleted
  }
}

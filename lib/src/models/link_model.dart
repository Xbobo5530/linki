import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:linki/src/models/link.dart';
import 'package:linki/src/models/user.dart';
import 'package:linki/src/values/consts.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

const _tag = 'LinkModel:';

abstract class LinkModel extends Model {
  final _database = Firestore.instance;

  Stream<QuerySnapshot> get linksStream => _database
      .collection(LINKS_COLLECTION)
      .orderBy(CREATED_AT_FIELD, descending: true)
      .snapshots();

  StatusCode _submittingLinkStatus;
  StatusCode get submittingLinkStatus => _submittingLinkStatus;
  StatusCode _deletingLinkStatus;
  StatusCode get deletingLinkStatus => _deletingLinkStatus;
  Map<String, Link> _links = Map();
  Map<String, Link> get links => _links;
  LinkiError _linkiErrorType;
  LinkiError get linkiError => _linkiErrorType;
  Link _lastSubmittedLink;
  List<String> _urlList = <String>[];
  LinkType _selctedLinkType;
  LinkType get selectedLinkType => _selctedLinkType;

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
      link.decodedTitle = link.decodeString(link.title);
      link.decodedDescription = link.decodeString(link.description);
      tempList.putIfAbsent(document.documentID, () => link);
    });

    _links = tempList;
    notifyListeners();
    _makeUrlList();
    return StatusCode.success;
  }

  _makeUrlList() {
    print('$_tag at _makeUrlList');
    List<String> tempUrlList = <String>[];
    _links.forEach((id, link) {
      tempUrlList.add(link.url);
    });
    _urlList = tempUrlList;
  }

  resetSubmitStatus() {
    _submittingLinkStatus = null;
    _linkiErrorType = null;
    notifyListeners();
  }

  bool _isValidUrlScheme(String url) {
    return url.contains(WHATSAPP_URL_SCHEME) ||
        url.contains(TELEGRAM_URL_SCHEME);
  }

  Future<StatusCode> submitLink(String url, User user) async {
    print('$_tag at submitLink');

    _submittingLinkStatus = StatusCode.waiting;
    notifyListeners();
    if (!_isValidUrlScheme(url)) {
      _linkiErrorType = LinkiError.invalidUrlScheme;
      _submittingLinkStatus = StatusCode.failed;
      notifyListeners();
      return _submittingLinkStatus;
    }
    if (_linkAlreadyExists(url)) {
      _linkiErrorType = LinkiError.urlAlreadyExists;
      _submittingLinkStatus = StatusCode.failed;
      return _submittingLinkStatus;
    }
    _submittingLinkStatus = await _processLink(url, user);
    notifyListeners();

    if (_submittingLinkStatus == StatusCode.success) _updateLinks();
    return _submittingLinkStatus;
  }

  /// updates the local list of links after [currentUser] submits a new link
  /// it runs after the [submitLink()] is ran
  _updateLinks() {
    _links.putIfAbsent(_lastSubmittedLink.id, () => _lastSubmittedLink);
  }

  bool _linkAlreadyExists(String url) {
    return _urlList.contains(url);
  }

  Future<StatusCode> _processLink(String url, User user) async {
    // print('$_tag at process link');
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

  int _getType(String url) {
    if (url.contains(WHATSAPP_URL_SCHEME)) return LINK_TYPE_WHATSAPP;
    if (url.contains(TELEGRAM_URL_SCHEME)) return LINK_TYPE_TELEGRAM;
    return 0;
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
      TYPE_FIELD: _getType(url),
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch
    };
    DocumentReference documentRef = await _database
        .collection(LINKS_COLLECTION)
        .add(linkMap)
        .catchError((error) {
      print('$_tag there was an error: $error');
      _hasError = true;
    });

    if (_hasError) return StatusCode.failed;
    _createLinkRefForUser(documentRef, user);
    _lastSubmittedLink = await _getLinkFromId(documentRef.documentID);
    return StatusCode.success;
  }

  Future<StatusCode> _createLinkRefForUser(
      DocumentReference documentRef, User user) async {
    print('$_tag at _createUserRef');
    bool _hasError = false;
    Map<String, dynamic> userRefMap = {
      CREATED_BY_FIELD: user.id,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch,
      LINK_ID_FIELD: documentRef.documentID
    };
    await _database
        .collection(USERS_COLLECTION)
        .document(user.id)
        .collection(LINKS_COLLECTION)
        .add(userRefMap)
        .catchError((error) {
      print('$_tag error on creating a link ref doc for user: $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<StatusCode> deleteLink(Link link) async {
    // print('$_tag at deleteLink');
    bool _hasError = false;
    await Firestore.instance
        .collection(LINKS_COLLECTION)
        .document(link.id)
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
    _links.remove(link.id);

    _deletingLinkStatus = StatusCode.success;
    notifyListeners();
    return _deletingLinkStatus;
  }

  openLink(Link link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch ${link.url}';
    }
  }

  initiateContact(ContactType type) async {
    // print('$_tag at initiateContact');
    String url;
    switch (type) {
      case ContactType.phone:
        url = CONTACT_PHONE_URL;
        break;
      case ContactType.email:
        url = CONTACT_EMAIL_URL;
        break;
      default:
        print('$_tag unexpected contact type: $type');
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  share(Link link) {
    final _shareText =
        '${link.title}\n${link.url}\nshared from Linki: $LINKI_DOWNLOAD_URL';
    Share.share(_shareText);
  }

  Future<StatusCode> report(Link link) async {
    final reports = link.reports;
    if (reports == MAX_ALLOWED_REPORTS) {
      deleteLink(link);
      return StatusCode.success;
    }
    return await _updateReports(link);
  }

  Future<StatusCode> _updateReports(Link link) async {
    // print('$_tag at _updateReports');
    bool _hasError = false;
    Map<String, int> reportMap = {REPORTS_FIELD: 1};

    await _database.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction
          .get(_database.collection(LINKS_COLLECTION).document(link.id));
      if (freshSnap[REPORTS_FIELD] == null)
        await freshSnap.reference.updateData(reportMap).catchError((error) {
          print('$_tag error on creating first report: $error');
          _hasError = true;
        });
      await transaction.update(freshSnap.reference,
          {REPORTS_FIELD: freshSnap[REPORTS_FIELD] + 1}).catchError((error) {
        print('$_tag error on performing transaction for reports: $error');
        _hasError = true;
      });
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<Link> _getLinkFromId(String id) async {
    // print('$_tag at getLinkFromId');
    bool _hasError = false;
    DocumentSnapshot document = await _database
        .collection(LINKS_COLLECTION)
        .document(id)
        .get()
        .catchError((error) {
      print('$_tag error on getting linkg document from id');
      _hasError = true;
    });
    if (_hasError || !document.exists) return null;
    return Link.fromSnapshot(document);
  }

  updateSelectedLinkType(LinkType type) {
    // print('$_tag at updateSelectedLinkType');
    _selctedLinkType = type;
    notifyListeners();
  }

  int _getLinkTypeAsInt(LinkType type) {
    switch (type) {
      case LinkType.whatsApp:
        return LINK_TYPE_WHATSAPP;
        break;
      case LinkType.telegram:
        return LINK_TYPE_TELEGRAM;
        break;
      default:
        return 0;
    }
  }

  List<Link> _getLinksFor(LinkType type) {
    // print('$_tag at _getLinksFor\nthe linkType is: $type');
    List<Link> tempList = [];
    _links.forEach((id, link) {
      if (link.type == _getLinkTypeAsInt(type)) {
        tempList.add(link);
      }
    });
    return tempList;
  }

  List<Link> _allLinks() {
    List<Link> tempList = [];
    _links.forEach((id, link) {
      tempList.add(link);
    });
    return tempList;
  }

  List<Link> getLinksForSelectedType(LinkType type) {
    switch (type) {
      case LinkType.whatsApp:
        return _getLinksFor(LinkType.whatsApp);
        break;
      case LinkType.telegram:
        return _getLinksFor(LinkType.telegram);
        break;
      default:
        return _allLinks();
    }
  }
}

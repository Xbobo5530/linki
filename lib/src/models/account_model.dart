import 'package:linki/src/models/user.dart';
import 'package:linki/src/values/consts.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _tag = 'AccountModdel:';

abstract class AccountModel extends Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Firestore _database = Firestore.instance;

  StatusCode _loginStatus;
  StatusCode get loginStatus => _loginStatus;
  StatusCode _logoutStatus;
  StatusCode get logoutStatus => _logoutStatus;

  User _currentUser;
  User get currentUser => _currentUser;
  StatusCode _updatingLoginStatus;
  StatusCode get updatingCurrentUserStatus => _updatingLoginStatus;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<StatusCode> signInWithGoole() async {
    print('$_tag at signInWithGoogle');
    _loginStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    final GoogleSignInAccount googleUser =
        await _googleSignIn.signIn().catchError((error) {
      print('$_tag error on signing in with google: $error');
      _hasError = true;
    });
    if (_hasError) {
      _loginStatus = StatusCode.failed;
      notifyListeners();
      return _loginStatus;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth
        .signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    )
        .catchError((error) {
      print('$_tag error on authenticatin user $error');
      _hasError = true;
    });
    if (_hasError) {
      _loginStatus = StatusCode.failed;
      notifyListeners();
      return _loginStatus;
    }
    if (user == null) {
      _loginStatus = StatusCode.failed;
      notifyListeners();
      return _loginStatus;
    }
    _loginStatus = await _checkIfUserExists(user);
    updateLoginStatus();
    notifyListeners();
    return _loginStatus;
  }

  Future<StatusCode> updateLoginStatus() async {
    print('$_tag at updateCurrentUser');
    bool _hasError = false;
    FirebaseUser user = await _auth.currentUser().catchError((error) {
      print('$_tag error on getting current user $error');
      _hasError = true;
    });
    if (_hasError) {
      _isLoggedIn = false;
      _updatingLoginStatus = StatusCode.failed;
      notifyListeners();
      return _updatingLoginStatus;
    }

    if (user == null) {
      _isLoggedIn = false;
      _currentUser = null;
      _updatingLoginStatus = StatusCode.success;
      notifyListeners();
      return _updatingLoginStatus;
    }

    _updatingLoginStatus = await _updateCurrentUser(user);
    notifyListeners();
    return _updatingLoginStatus;
  }

  Future<StatusCode> _updateCurrentUser(FirebaseUser user) async {
    print('$_tag at _updateCurrentUser');
    bool _hasError = false;
    DocumentSnapshot document = await _database
        .collection(USERS_COLLECTION)
        .document(user.uid)
        .get()
        .catchError((error) {
      print('$_tag error on getting current user doc $error');
      _hasError = true;
    });
    if (_hasError || !document.exists) {
      _updatingLoginStatus = StatusCode.failed;
      notifyListeners();
      return StatusCode.failed;
    }

    User currentUser = User.fromSnapshot(document);
    _currentUser = currentUser;
    _isLoggedIn = true;
    _updatingLoginStatus = StatusCode.success;
    notifyListeners();
    return _updatingLoginStatus;
  }

  Future<StatusCode> _checkIfUserExists(FirebaseUser user) async {
    print('$_tag at _checkIfUserExists');
    bool _hasError = false;
    final userId = user.uid;
    DocumentSnapshot document = await _database
        .collection(USERS_COLLECTION)
        .document(userId)
        .get()
        .catchError((error) {
      print('$_tag error on getting user documnet');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    if (!document.exists) return await _createUserDoc(user);
    return StatusCode.success;
  }

  Future<StatusCode> _createUserDoc(FirebaseUser user) async {
    print('$_tag at _createUserDoc');
    bool _hasError = false;
    Map<String, dynamic> userMap = {
      NAME_FIELD: user.displayName,
      IMAGE_URL_FIELD: user.photoUrl,
      IS_ADMIN_FIELD: false,
      CREATED_AT_FIELD: DateTime.now().millisecondsSinceEpoch
    };
    await _database
        .collection(USERS_COLLECTION)
        .document(user.uid)
        .setData(userMap)
        .catchError((error) {
      print('$_tag error on creating user doc $error');
      _hasError = true;
    });
    if (_hasError) return StatusCode.failed;
    return StatusCode.success;
  }

  Future<StatusCode> logout() async {
    print('$_tag at logout');
    _logoutStatus = StatusCode.waiting;
    notifyListeners();
    bool _hasError = false;
    await _auth.signOut().catchError((error) {
      print('$_tag error on logging out');
      _logoutStatus = StatusCode.failed;
      notifyListeners();
      _hasError = true;
    });
    if (_hasError) return _logoutStatus;
    _logoutStatus = await updateLoginStatus();
    notifyListeners();

    return _loginStatus;
  }
}

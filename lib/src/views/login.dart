import 'package:flutter/material.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';

import 'package:linki/src/views/waiting.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'LoginView:';

class LoginDialog extends StatelessWidget {
  final Intent intent;

  const LoginDialog({Key key, this.intent}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (_, __, model) => SimpleDialog(
              title: Text(loginText),
              children: model.loginStatus == StatusCode.waiting
                  ? <Widget>[WaitingView()]
                  : _buildContent(model, context),
            ));
  }

  Future<void> _handleLogin(BuildContext context, MainModel model) async {
    StatusCode loginStatus = await model.signInWithGoole();
    if (loginStatus == StatusCode.failed) return;
    Navigator.pop(context);
  }

  _buildMessageSection(MainModel model) => ListTile(
      title: Text(
          model.loginStatus == StatusCode.failed ? errorMessage : loginMessage,
          style: TextStyle(
              // fontSize: 16.0,
              color: model.loginStatus == StatusCode.failed
                  ? Colors.red
                  : Colors.black)));

  _buildContent(MainModel model, BuildContext context) => <Widget>[
        _buildMessageSection(model),
        SimpleDialogOption(
            child: Text(loginText.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.deepOrange)),
            onPressed: () => _handleLogin(context, model)),
        SimpleDialogOption(
            child: Text(cancelText.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.pop(context);
              model.resetLoginStatus();
            }),
      ];
}

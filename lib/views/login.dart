import 'package:flutter/material.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';

import 'package:linki/views/waiting.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'LoginView:';

class LoginDialog extends StatelessWidget {
  final Intent intent;

  const LoginDialog({Key key, this.intent}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // _showAddLinkDialog() async => await showDialog(
    //     context: context, builder: (context) => AddLinkDialog());

    Future<void> _handleLogin(BuildContext context, MainModel model) async {
      StatusCode loginStatus = await model.signInWithGoole();
      switch (loginStatus) {
        case StatusCode.success:
          Navigator.pop(context);
          // if (intent == Intent.addLink) _showAddLinkDialog();
          break;
        default:
          print('$_tag unexpected login status code: $loginStatus');
      }
    }

    _buildMessageSection(MainModel model) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            model.loginStatus == StatusCode.failed
                ? errorMessage
                : loginMessage,
            style: TextStyle(
                fontSize: 16.0,
                color: model.loginStatus == StatusCode.failed
                    ? Colors.red
                    : Colors.black),
          ),
        );

    _buildLoginButton(MainModel model) => FlatButton(
        textColor: Colors.deepOrange,
        child: Text(
          model.loginStatus == StatusCode.waiting
              ? waitText.toUpperCase()
              : loginText.toUpperCase(),
          style: TextStyle(fontSize: 16.0),
        ),
        onPressed: () => _handleLogin(context, model));

    _buildCancelButton(MainModel model) => FlatButton(
          child: Text(cancelText.toUpperCase()),
          onPressed: () => Navigator.pop(context),
        );

    _buildActions(MainModel model) => Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[_buildLoginButton(model)],
              ),
              _buildCancelButton(model),
            ],
          ),
        );

    _buildContent(MainModel model) => Column(children: <Widget>[
          _buildMessageSection(model),
          _buildActions(model),
        ]);

    return ScopedModelDescendant<MainModel>(
        builder: (_, __, model) => SimpleDialog(
              title: Text(loginText),
              children: model.loginStatus == StatusCode.waiting
                  ? <Widget>[WaitingView()]
                  : <Widget>[_buildContent(model)],
            ));
  }
}

import 'package:flutter/material.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';
import 'package:linki/views/add_link.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'LoginView:';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _showAddLinkDialog() async => await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text(addLinkText),
              children: <Widget>[AddLinkView()],
            ));

    Future<void> _handleLogin(BuildContext context, MainModel model) async {
      StatusCode loginStatus = await model.signInWithGoole();
      switch (loginStatus) {
        case StatusCode.success:
          Navigator.pop(context);
          _showAddLinkDialog();
          break;
        default:
          print('$_tag unexpected login status code: $loginStatus');
      }
    }

    return ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            model.loginStatus == StatusCode.failed
            ? errorMessage
            : loginMessage,
            style: TextStyle(fontSize: 16.0, 
            color: model.loginStatus == StatusCode.failed
            ? Colors.red
            : Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                      textColor: Colors.deepOrange,
                      child: Text(
                        loginText.toUpperCase(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onPressed: () => _handleLogin(context, model))
                ],
              ),
              FlatButton(
                child: Text(cancelText.toUpperCase()),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ]);
    });
  }
}

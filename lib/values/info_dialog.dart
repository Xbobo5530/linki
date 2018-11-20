import 'package:flutter/material.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';
import 'package:scoped_model/scoped_model.dart';

class InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _actionButtons = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ScopedModelDescendant<MainModel>(
        builder: (_, __, model) => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    callUsText,
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  onPressed: () {
                    model.initiateContact(ContactType.phone);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text(
                    emailUsText,
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  onPressed: () {
                    model.initiateContact(ContactType.email);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
      ),
    );

    final _bodySection = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(devByText),
    );

    return SimpleDialog(
      title: Text(APP_NAME),
      children: <Widget>[_bodySection, _actionButtons],
    );
  }
}

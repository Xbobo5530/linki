import 'package:flutter/material.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';
import 'package:scoped_model/scoped_model.dart';

class InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ScopedModelDescendant<MainModel>(
        builder: (context, child, model) => SimpleDialog(
              title: Text(APP_NAME),
              children: <Widget>[
                ListTile(
                    title: Text(devByText),
                    subtitle: Text(reportProfanityWarningMessage,
                        style: TextStyle(color: Colors.redAccent))),
                SimpleDialogOption(
                  child: Text(callUsText.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.deepOrange)),
                  onPressed: () {
                    model.initiateContact(ContactType.phone);
                    Navigator.pop(context);
                  },
                ),
                SimpleDialogOption(
                    child: Text(emailUsText.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.deepOrange)),
                    onPressed: () {
                      model.initiateContact(ContactType.email);
                      Navigator.pop(context);
                    }),
              ],
            ),
      );
}

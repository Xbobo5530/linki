import 'package:flutter/material.dart';
import 'package:linki/values/strings.dart';

class AddLinkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(addLinkText),
      ),
      body: Column(
        children: <Widget>[
          TextField(
      
            decoration: InputDecoration(
              labelText: groupLinkText, border: OutlineInputBorder()),
          )
        ],
      ),
    );
  }
}

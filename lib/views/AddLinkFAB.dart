import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:linki/values/strings.dart';
import 'package:http/http.dart' as http;

const tag = 'AddLinkFAB:';

class AddLinkFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      onPressed: () => _showDialog(context),
      tooltip: 'Add link',
      child: new Icon(Icons.add),
    );
  }

  final mController = TextEditingController();

  _showDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new TextField(
              decoration: new InputDecoration(labelText: enterLinkLabelText),
              controller: mController,
            ),
            actions: <Widget>[
              ButtonBar(
                children: <Widget>[
                  new FlatButton(
                      onPressed: () {
                        mController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text(cancelText)),
                  new FlatButton(
                    onPressed: () => _submit(context, mController),
                    child: const Text(submitText),
                  )
                ],
              )
            ],
          );
        });
  }

  void _submit(BuildContext context, TextEditingController controller) {
    String url = mController.text;
    if (url.contains(WHATSAPP_DOT_COM)) {
      _processLink(url);
      controller.clear();
      Navigator.pop(context);
    } else {
      _showWarningDialog(context);
    }
  }

  void _addLink(String url, title, imageUrl, description) {
    var linkMap = {
      'url': url,
      'title': title,
      'image_url': imageUrl,
      'description': description,
      'created_at': DateTime.now().millisecondsSinceEpoch
    };
    Firestore.instance
        .collection(LINKS_COLLECTION)
        .add(linkMap)
        .whenComplete(() {
      print('$tag the link has been successfully added');
    }).catchError((error) {
      error != null
          ? print('$tag there was an error: $error')
          : print('$tag no error on adding link');
    });
  }

  Future _showWarningDialog(BuildContext context) {
    mController.clear();
    Navigator.pop(context);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(errorText),
            content: const Text('Please enter a WhatsApp link'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(okText))
            ],
          );
        });
  }

  void _processLink(String url) {
    print('$tag at process link');
    http.get(url, headers: {'title': 'title'}).then((response) {
      var titleTag = '<meta property="og:title" content="';
      var imageUrlTag = '<meta property="og:image" content="';
      var descriptionTag = '<meta property="og:description" content="';

      var title = _getValueFrom(response, titleTag);
      var imageUrl = _getValueFrom(response, imageUrlTag);
      var description = _getValueFrom(response, descriptionTag);

      _addLink(url, title, imageUrl, description);
    });
  }

  _getValueFrom(Response response, String tag) {
    var body = response.body;
    //var titleTag = format; //'<meta property="og:title" content="';
    var tagLength = tag.length;
    var tagStartPos = body.indexOf(tag) + tagLength;
    var tagEndPos = body.indexOf('"', tagStartPos);
    return body.substring(tagStartPos, tagEndPos);
  }
}

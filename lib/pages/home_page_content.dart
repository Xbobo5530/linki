import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:linki/models/link.dart';
import 'package:linki/views/link_item_view.dart';
//import 'package:html/dom.dart';
//import 'package:html/dom.dart';

const tag = 'MyHomePage:';
const LINKS_COLLECTION = 'Links';
const _WHATSAPP_DOT_COM = 'whatsapp.com';
const _submitText = 'Submit';
const _enterLinkLabelText = 'Enter a WhatsApp Group link';
const _cancelText = 'Cancel';
const _okText = 'OK';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new StreamBuilder(
        stream: Firestore.instance.collection(LINKS_COLLECTION).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: new CircularProgressIndicator());
          return new ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.documents[index];
              var link = Link.fromSnapshot(ds);
              return new LinkItemView(link); /*new Text("${ds['url']}");*/
            },
          );
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _showDialog();
        },
        tooltip: 'Add link',
        child: new Icon(Icons.add),
      ),
    );
  }

  final mController = TextEditingController();

  _showDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new TextField(
              decoration: new InputDecoration(labelText: _enterLinkLabelText),
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
                      child: const Text(_cancelText)),
                  new FlatButton(
                    onPressed: () => _submit(context, mController),
                    child: const Text(_submitText),
                  )
                ],
              )
            ],
          );
        });
  }

  void _submit(BuildContext context, TextEditingController controller) {
    String url = mController.text;
    if (url.contains(_WHATSAPP_DOT_COM)) {
      _processLink(url);
      controller.clear();
      Navigator.pop(context);
    } else {
      _showWarningDialog();
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
    Firestore.instance.collection(LINKS_COLLECTION).add(linkMap);
  }

  Future _showWarningDialog() {
    mController.clear();
    Navigator.pop(context);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a WhatsApp link'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(_okText))
            ],
          );
        });
  }

  void _processLink(String url) {
    print('$tag at process link');
    http.get(url, headers: {'title': 'title'}).then((response) {
//      print(
//          '$tag $response\nResponse status: ${response.statusCode}\nResponse body: ${response.body}');
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

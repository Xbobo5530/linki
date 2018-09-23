import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:linki/models/link.dart';
import 'package:linki/pages/search_dialog.dart';
import 'package:linki/values/strings.dart';
import 'package:linki/views/link_item_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
//import 'package:html/dom.dart';
//import 'package:html/dom.dart';

const tag = 'MyHomePage:';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var linkList = new List<Link>();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Image.asset(
            APP_ICON,
            scale: 0.1,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () => _showInfoDialog(context),
          ),
          IconButton(
              icon: new Icon(Icons.search),
              onPressed: () => _openSearchDialog(
                  context, linkList)) /*_openSearchDialog(context, linkList))*/
        ],
      ),
      body: new StreamBuilder(
        stream: Firestore.instance
            .collection(LINKS_COLLECTION)
            .orderBy(CREATED_AT, descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: new CircularProgressIndicator());

          //add links to link list for local search

          for (DocumentSnapshot document in snapshot.data.documents) {
            var link = Link.fromSnapshot(document);
            linkList.add(link);
          }

          return new ListView.builder(
            itemCount: linkList.length,
            itemBuilder: (context, index) {
              return new LinkItemView(linkList[index]);
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

  void _showInfoDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text(appInfoText),
            content: new Text(devByText),
            actions: <Widget>[
              FlatButton(
                child: Text('Contact us'),
                onPressed: () {
                  _initiateContact();
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void _initiateContact() async {
    var url = 'tel: +2550713810803';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _openSearchDialog(BuildContext context, List<Link> linkList) {
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new SearchDialog(linkList),
          fullscreenDialog: true),
    );
  }
}

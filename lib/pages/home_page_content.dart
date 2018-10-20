import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:linki/models/link.dart';
import 'package:linki/pages/search_dialog.dart';
import 'package:linki/values/strings.dart';
import 'package:linki/views/AddLinkFAB.dart';
import 'package:linki/views/link_item_view.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:html/dom.dart';lsof -wni tcp:60440lsof -wni tcp:60440
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
            var linkId = document.documentID;
            var link = Link.fromSnapshot(document);
            link.id = linkId;
            linkList.add(link);
          }

          return new ListView.builder(
            itemCount: snapshot.data.documents.length /*linkList.length*/,
            itemBuilder: (context, index) {
              var document = snapshot.data.documents[index];
              var link = Link.fromSnapshot(document);
              return LinkItemView(link /*linkList[index]*/);
            },
          );
        },
      ),
//        floatingActionButton: AddLinkFAB()
    );
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

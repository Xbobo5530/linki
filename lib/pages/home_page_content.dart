import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:linki/pages/search_dialog.dart';
import 'package:linki/values/strings.dart';
import 'package:linki/views/link_item_view.dart';
import 'package:url_launcher/url_launcher.dart';

const tag = 'MyHomePage:';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var linkList = List<Link>();

  //todo test if info dialog still works
  _showInfoDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(appInfoText),
            content: Text(devByText),
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

  _openSearchDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SearchDialog(linkList), fullscreenDialog: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            APP_ICON,
            scale: 0.1,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () => _showInfoDialog(),
          ),
          IconButton(
              icon: Icon(Icons.search), onPressed: () => _openSearchDialog())
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection(LINKS_COLLECTION)
            .orderBy(CREATED_AT, descending: true)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          //add links to link list for local search
          for (DocumentSnapshot document in snapshot.data.documents) {
            var linkId = document.documentID;
            var link = Link.fromSnapshot(document);
            link.id = linkId;
            linkList.add(link);
          }

          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (_, index) {
              var document = snapshot.data.documents[index];
              var link = Link.fromSnapshot(document);
              return LinkItemView(link);
            },
          );
        },
      ),
    );
  }

  void _initiateContact() async {
    var url = 'tel: +2550713810803';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

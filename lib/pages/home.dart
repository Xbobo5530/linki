import 'package:flutter/material.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/pages/add_link.dart';
import 'package:linki/values/consts.dart';
import 'package:linki/values/strings.dart';

import 'package:linki/models/link.dart';
import 'package:linki/pages/search_dialog.dart';
// import 'package:linki/views/AddLinkFab.dart';
import 'package:linki/views/link_item_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

// const _tag = 'MyHomePage:';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Link> linkList = List<Link>();

    void _initiateContact() async {
      var url = CONTACT_URL;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    _showInfoDialog() async {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(appInfoText),
              content: Text(devByText),
              actions: <Widget>[
                RaisedButton(
                  color: Colors.white,
                  textColor: Colors.black,
                  child: Text(
                    contactUsText,
                  ),
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
            builder: (context) => SearchDialog(linkList),
            fullscreenDialog: true),
      );
    }

    final _appBar = AppBar(
      elevation: 0.0,
      title: Text(APP_NAME),
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
    );

    final _bodySection = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return StreamBuilder(
          stream: model.linksStream,
          builder: (_, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (_, index) {
                var document = snapshot.data.documents[index];
                var link = Link.fromSnapshot(document);

                return ScopedModelDescendant<MainModel>(
                  builder: (_, __, model) {
                    return Dismissible(
                      key: Key(link.id),
                      child: LinkItemView(
                        link: link,
                      ),
                      background: Container(
                        color: Colors.red,
                        child: Icon(Icons.delete),
                      ),
                      onDismissed: (_) => model.deleteLink(index, link.id),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: _appBar,
      body: _bodySection,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => AddLinkPage(), fullscreenDialog: true)),
      ),
    );
  }
}

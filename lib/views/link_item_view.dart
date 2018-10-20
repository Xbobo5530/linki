import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:linki/values/strings.dart';
import 'package:url_launcher/url_launcher.dart';

const tag = 'LinkItemView';

class LinkItemView extends StatelessWidget {
  final Link link;
  LinkItemView({this.link});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: link.imageUrl != null
            ? NetworkImage(link.imageUrl)
            : AssetImage('assets/icon-foreground.png'),
      ),
      title: Text(link.title),
      subtitle: Text(link.description),
      onTap: () => _openLink(link.url),
    );
  }

  _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

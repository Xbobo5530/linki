import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkItemView extends StatelessWidget {
  final Link link;
  LinkItemView(this.link);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: new ListTile(
        leading: new CircleAvatar(
          backgroundImage: link.imageUrl != null
              ? NetworkImage(link.imageUrl)
              : AssetImage('assets/icon-foreground.png'),
        ),
        title: new Text(link.title),
        subtitle: new Text(link.description),
      ),
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

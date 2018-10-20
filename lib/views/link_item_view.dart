import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

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
      trailing: IconButton(
        icon: Icon(Icons.share),
        onPressed: () => Share.share(link.url),
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

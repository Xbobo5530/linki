import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';
import 'package:scoped_model/scoped_model.dart';

const tag = 'LinkItemView';

class LinkItemView extends StatelessWidget {
  final Link link;

  const LinkItemView({Key key, this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        bool isLinkOwner = model.isLoggedIn && model.currentUser.id == link.createdBy;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black12,
            backgroundImage: link.imageUrl != null
                ? NetworkImage(link.imageUrl)
                : AssetImage('assets/icon-foreground.png'),
          ),
          title: Text(link.title),
          subtitle: Text(link.description),
          trailing: PopupMenuButton<MenuOption>(
            itemBuilder: (
              _,
            ) =>
                <PopupMenuEntry<MenuOption>>[
                  const PopupMenuItem(
                    child: Text(openText),
                    value: MenuOption.open,
                  ),
                  const PopupMenuItem(
                    child: Text(shareText),
                    value: MenuOption.share,
                  ),
                  PopupMenuItem(
                    child: Text(isLinkOwner ? deleteText : reportText),
                    value: isLinkOwner ? MenuOption.share : MenuOption.report,
                  )
                ],
          ),
          onTap: () => model.openLink(link.url),
        );
      },
    );
  }
}

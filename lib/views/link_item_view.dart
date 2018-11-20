import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'LinkItemView';

class LinkItemView extends StatelessWidget {
  final Link link;

  const LinkItemView({Key key, @required this.link})
      : assert(link != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _handleMenuActions(MainModel model, MenuOption option) {
      switch (option) {
        case MenuOption.open:
          model.openLink(link);
          break;
        case MenuOption.delete:
          model.deleteLink(link);
          break;
        case MenuOption.share:
          model.share(link);
          break;
        case MenuOption.report:
          model.report(link);
          break;
        default:
          print('$_tag unexpected menu option $option');
      }
    }

    _buildPopUpMenuButton(MainModel model, bool isLinkOwner) =>
        PopupMenuButton<MenuOption>(
          onSelected: (option) => _handleMenuActions(model, option),
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
                  value: isLinkOwner ? MenuOption.delete : MenuOption.report,
                )
              ],
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        bool isLinkOwner = model.isLoggedIn &&
            (model.currentUser.id == link.createdBy ||
                model.currentUser.isAdmin);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black12,
            backgroundImage: link.imageUrl != null
                ? NetworkImage(link.imageUrl)
                : AssetImage('assets/icon-foreground.png'),
          ),
          title: Text(link.title),
          subtitle: Text(link.description),
          trailing: _buildPopUpMenuButton(model, isLinkOwner),
          onTap: () => model.openLink(link),
        );
      },
    );
  }
}

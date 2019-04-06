import 'package:flutter/material.dart';
import 'package:linki/src/models/link.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/consts.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';
import 'package:linki/src/views/login.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'LinkItemView';

class LinkListItemView extends StatelessWidget {
  final Link link;

  const LinkListItemView({Key key, @required this.link})
      : assert(link != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        bool isLinkOwner = model.isLoggedIn &&
            (model.currentUser.id == link.createdBy ||
                model.currentUser.isAdmin);
        return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black12,
              backgroundImage: AssetImage(_assetImage()),
            ),
            // child: Text(link.title[0],
            //     style: TextStyle(color: Colors.black))),
            title: Text(link.decodedTitle, softWrap: true),
            subtitle: Text(link.decodedDescription, softWrap: true),
            trailing: _buildPopUpMenuButton(model, context, isLinkOwner),
            onTap: () => model.openLink(link));
      },
    );
  }

  _handleReport(MainModel model, BuildContext context) async {
    StatusCode reportStatus = await model.report(link);
    switch (reportStatus) {
      case StatusCode.success:
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(reportSubmittedMessage)));
        break;
      case StatusCode.failed:
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
        break;
      default:
        print('$_tag unexpected report status: $reportStatus');
    }
  }

  _showLoginDialog(BuildContext context, Intent intent) async =>
      await showDialog(
          context: context, builder: (context) => LoginDialog(intent: intent));

  _handleMenuActions(MainModel model, BuildContext context, MenuOption option) {
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
        model.isLoggedIn
            ? _handleReport(model, context)
            : _showLoginDialog(context, Intent.login);
        break;
      default:
        print('$_tag unexpected menu option $option');
    }
  }

  _buildPopUpMenuButton(
          MainModel model, BuildContext context, bool isLinkOwner) =>
      PopupMenuButton<MenuOption>(
        onSelected: (option) => _handleMenuActions(model, context, option),
        itemBuilder: (context) => <PopupMenuEntry<MenuOption>>[
              PopupMenuItem(child: Text(openText), value: MenuOption.open),
              PopupMenuItem(child: Text(shareText), value: MenuOption.share),
              PopupMenuItem(
                  child: Text(isLinkOwner ? deleteText : reportText),
                  value: isLinkOwner ? MenuOption.delete : MenuOption.report)
            ],
      );

  String _assetImage() {
    switch (link.type) {
      case LINK_TYPE_WHATSAPP:
        return ASSET_IMAGE_WHATSAPP_ICON;
      case LINK_TYPE_TELEGRAM:
        return ASSET_IMAGE_TELEGRAM_ICON;
      default:
        return ASSET_IMAGE_APP_ICON;
    }
  }
}

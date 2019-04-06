import 'package:flutter/material.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/consts.dart';
import 'package:linki/src/values/info_dialog.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';
import 'package:linki/src/pages/search_dialog.dart';
import 'package:linki/src/views/add_link.dart';
import 'package:linki/src/views/home_body.dart';
import 'package:linki/src/views/login.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'MyHomePage:';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _searchButton =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return IconButton(
          icon: Icon(Icons.search),
          onPressed: () => showSearch(
                context: context,
                delegate: SearchLinks(links: model.links),
              ));
    });

    Widget _morePopUpButton =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return PopupMenuButton<MenuOption>(
          onSelected: (option) =>
              _handleSelectionMenuOption(model, context, option),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOption>>[
                PopupMenuItem(
                  value: MenuOption.appInfo,
                  child: Text(appInfoText),
                ),
                PopupMenuItem(
                  value:
                      model.isLoggedIn ? MenuOption.logout : MenuOption.login,
                  child: Text(model.isLoggedIn ? logoutText : loginText),
                )
              ]);
    });

    final _filterButton = ScopedModelDescendant<MainModel>(
        builder: (_, __, model) => PopupMenuButton<LinkType>(
              onSelected: (type) => _handleFilter(model, type),
              icon: Icon(Icons.filter_list),
              itemBuilder: (_) => <PopupMenuEntry<LinkType>>[
                    PopupMenuItem<LinkType>(
                      value: LinkType.all,
                      child: Text(allText),
                    ),
                    PopupMenuItem<LinkType>(
                      value: LinkType.whatsApp,
                      child: Text(whatsAppText),
                    ),
                    PopupMenuItem<LinkType>(
                      value: LinkType.telegram,
                      child: Text(telegramText),
                    )
                  ],
            ));

    final _title = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        switch (model.selectedLinkType) {
          case LinkType.all:
            return Text(APP_NAME);
            break;
          case LinkType.whatsApp:
            return Text(
              '$APP_NAME - $whatsAppText',
              softWrap: true,
            );
            break;
          case LinkType.telegram:
            return Text(
              '$APP_NAME - $telegramText',
              softWrap: true,
            );
            break;
          default:
            return Text(APP_NAME);
        }
      },
    );

    final _appBar = AppBar(
      elevation: 0.0,
      title: _title,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          APP_ICON,
          scale: 0.1,
        ),
      ),
      actions: <Widget>[
        _filterButton,
        _searchButton,
        _morePopUpButton,
      ],
    );

    final _fab = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return Transform.scale(
          scale: 2.0,
          origin: Offset(-5.0, -5.0),
          child: FloatingActionButton(
              elevation: 0.0,
              child: Icon(Icons.add),
              onPressed: model.isLoggedIn
                  ? () => _showAddLinkDialog(context)
                  : () => _showLoginDialog(context, Intent.addLink)),
        );
      },
    );

    return Scaffold(
      appBar: _appBar,
      body: HomeBodyView(),
      floatingActionButton: _fab,
    );
  }

  _showAddLinkDialog(BuildContext context) async =>
      await showDialog(context: context, builder: (_) => AddLinkDialog());
  _handleFilter(MainModel model, LinkType type) {
    model.updateSelectedLinkType(type);
  }

  _handleLogout(MainModel model, BuildContext context) async {
    StatusCode logoutStatus = await model.logout();
    switch (logoutStatus) {
      case StatusCode.success:
        Navigator.pop(context);
        break;
      default:
        print('$_tag unexpected logout status $logoutStatus');
    }
  }

  _buildMessageSection(MainModel model) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Text(
          model.logoutStatus == StatusCode.failed
              ? errorMessage
              : confirmLogoutText,
          style: TextStyle(fontSize: 16.0),
        ),
      );

  _buildActions(MainModel model, BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text(
                model.logoutStatus == StatusCode.waiting
                    ? waitText.toUpperCase()
                    : logoutText.toUpperCase(),
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () => _handleLogout(model, context),
            ),
            FlatButton(
              child: Text(cancelText.toUpperCase()),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );

  _showConfirmmationDialog(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => ScopedModelDescendant<MainModel>(
          builder: (_, __, model) => SimpleDialog(
                title: Text(logoutText),
                children: <Widget>[
                  _buildMessageSection(model),
                  _buildActions(model, context)
                ],
              )));

  _showLoginDialog(BuildContext context, Intent intent) async =>
      await showDialog(
          context: context, builder: (context) => LoginDialog(intent: intent));

  _handleSelectionMenuOption(
      MainModel model, BuildContext context, MenuOption option) {
    switch (option) {
      case MenuOption.appInfo:
        _showInfoDialog(context);
        break;
      case MenuOption.logout:
        _showConfirmmationDialog(context);
        break;
      case MenuOption.login:
        _showLoginDialog(context, Intent.login);
        break;
      default:
        print('$_tag unexpected option $option');
    }
  }

  _showInfoDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return InfoDialog();
        });
  }
}

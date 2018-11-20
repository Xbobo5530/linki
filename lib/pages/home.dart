import 'package:flutter/material.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/values/consts.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';

import 'package:linki/pages/search_dialog.dart';
import 'package:linki/views/add_link.dart';
import 'package:linki/views/home_body.dart';
import 'package:linki/views/login.dart';
import 'package:scoped_model/scoped_model.dart';


const _tag = 'MyHomePage:';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _showInfoDialog() async {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(appInfoText),
              content: Text(devByText),
              actions: <Widget>[
                ScopedModelDescendant<MainModel>(
                  builder: (_, __, model) {
                    return RaisedButton(
                      color: Colors.white,
                      textColor: Colors.black,
                      child: Text(
                        contactUsText,
                      ),
                      onPressed: () {
                        model.initiateContact();
                        Navigator.pop(context);
                      },
                    );
                  },
                )
              ],
            );
          });
    }

    final _searchButton =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return IconButton(
          icon: Icon(Icons.search),
          onPressed: () => showSearch(
                context: context,
                delegate: SearchLinks(links: model.links),
              ));
    });

    _handleLogout(MainModel model) async {
      StatusCode logoutStatus = await model.logout();
      switch (logoutStatus) {
        case StatusCode.success:
          Navigator.pop(context);
          break;
        default:
          print('$_tag unexpected logout status $logoutStatus');
      }
    }

    _showConfirmmationDialog() async => showDialog(
        context: context,
        builder: (context) => ScopedModelDescendant<MainModel>(
            builder: (_, __, model) => SimpleDialog(
                  title: Text(logoutText),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        model.logoutStatus == StatusCode.failed
                            ? errorMessage
                            : confirmLogoutText,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Padding(
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
                            onPressed: () => _handleLogout(model),
                          ),
                          FlatButton(
                            child: Text(cancelText.toUpperCase()),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    )
                  ],
                )));

    _showLoginDialog(MainModel model, Intent intent) async => await showDialog(
        context: context, builder: (context) => LoginDialog(intent: intent));

    _handleSelectionMenuOption(MainModel model, MenuOption option) {
      switch (option) {
        case MenuOption.appInfo:
          _showInfoDialog();
          break;
        case MenuOption.logout:
          _showConfirmmationDialog();
          break;
        case MenuOption.login:
          _showLoginDialog(model, Intent.login);
          break;
        default:
          print('$_tag unexpected option $option');
      }
    }

    Widget _morePopUpButton =
        ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return PopupMenuButton<MenuOption>(
          onSelected: (option) => _handleSelectionMenuOption(model, option),
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
        _searchButton,
        _morePopUpButton,
      ],
    );

    _showAddLinkDialog() async =>
        await showDialog(context: context, builder: (_) => AddLinkDialog());

    final _fab = ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: model.isLoggedIn
                ? () => _showAddLinkDialog()
                : () => _showLoginDialog(model, Intent.addLink));
      },
    );

    return Scaffold(
      appBar: _appBar,
      body: HomeBodyView(),
      floatingActionButton: _fab,
    );
  }
}

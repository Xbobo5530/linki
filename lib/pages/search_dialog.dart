import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:linki/values/strings.dart';
import 'package:linki/views/link_item_view.dart';

class SearchDialog extends StatefulWidget {
  final List<Link> linkList;
  SearchDialog(this.linkList);
  @override
  _SearchDialogState createState() => _SearchDialogState(linkList);
}

class _SearchDialogState extends State<SearchDialog> {
  final List<Link> linkList;
  var _searchText = '';
  List<Link> searchResults = [];
  var _searchFieldController = new TextEditingController();

  _SearchDialogState(this.linkList) {
    _searchFieldController.addListener(() {
      if (_searchFieldController.text.isEmpty) {
        setState(() {
          _searchText = '';
          searchResults = linkList;
        });
      } else {
        setState(() {
          _searchText = _searchFieldController.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new TextField(
            decoration: InputDecoration(
              hintText: searchHintText,
              prefixIcon: Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            autofocus: true,
            controller: _searchFieldController,
          ),
        ),
        body: new ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
//              searchResults.clear();
              if (_searchText.isNotEmpty) {
                List<Link> tempList = [];
                for (Link link in linkList) {
                  if (link.title
                      .toLowerCase()
                      .contains(_searchText.toLowerCase())) {
                    tempList.add(link);
                  }
                }
                searchResults = tempList;
              }
              if (searchResults.isNotEmpty)
                return LinkItemView(searchResults[index]);
              return Container();
            }));
  }
}

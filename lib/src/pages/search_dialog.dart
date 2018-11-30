import 'package:flutter/material.dart';
import 'package:linki/src/models/link.dart';
import 'package:linki/src/views/link_item_view.dart';

class SearchLinks extends SearchDelegate {
  final Map<String, Link> links;

  SearchLinks({this.links});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Link> resultsList = <Link>[];
    links.forEach((id, link) {
      if (link.title.toLowerCase().contains(query.toLowerCase()))
        resultsList.add(link);
    });

    return ListView(
      children: resultsList
          .map((link) => LinkItemView(
                link: link,
                key: Key(link.id),
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Link> resultsList = <Link>[];
    links.forEach((id, link) {
      if (link.title.toLowerCase().contains(query.toLowerCase()))
        resultsList.add(link);
    });

    return ListView(
      children: resultsList
          .map((link) => LinkItemView(
                link: link,
                key: Key(link.id),
              ))
          .toList(),
    );
  }
}

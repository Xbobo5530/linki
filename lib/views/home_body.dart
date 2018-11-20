import 'package:flutter/material.dart';
import 'package:linki/models/link.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/views/link_item_view.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeBodyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      return StreamBuilder(
        stream: model.linksStream,
        builder: (_, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (_, index) {
                final document = snapshot.data.documents[index];
                final link = Link.fromSnapshot(document);

                return LinkItemView(
                  link: link,
                );
              });
        },
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:linki/src/models/link.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/views/link_item_view.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeBodyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (_, __, model) {
      switch (model.selectedLinkType) {
        case LinkType.whatsApp:
          return ListView.builder(
              itemCount:
                  model.getLinksForSelectedType(LinkType.whatsApp).length,
              itemBuilder: (context, index) => LinkListItemView(
                    link:
                        model.getLinksForSelectedType(LinkType.whatsApp)[index],
                  ));

        case LinkType.telegram:
          return ListView.builder(
              itemCount:
                  model.getLinksForSelectedType(LinkType.telegram).length,
              itemBuilder: (context, index) => LinkListItemView(
                    link:
                        model.getLinksForSelectedType(LinkType.telegram)[index],
                  ));

        default:
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
                    link.decodedTitle = link.decodeString(link.title);
                    link.decodedDescription =
                        link.decodeString(link.description);

                    return LinkListItemView(link: link, key: Key(link.id));
                  });
            },
          );
      }
    });
  }
}

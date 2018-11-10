import 'package:flutter/material.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/values/status_code.dart';
import 'package:linki/values/strings.dart';
import 'package:linki/views/my_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'AddLinkPage:';

class AddLinkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mController = TextEditingController();
    _handleSubmitLink(BuildContext context, MainModel model) async {
      final url = mController.text.trim();
      if (url.isEmpty) return null;
      if (url.contains(WHATSAPP_DOT_COM)) {
        // hanle whatsapp link
        StatusCode statusCode = await model.submitLink(url);
        switch (statusCode) {
          case StatusCode.failed:
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text(errorMessage)));
            break;
          case StatusCode.success:
            Navigator.pop(context);
            break;
          default:
            print('$_tag the status code is: $statusCode');
        }
        return null;
      }
      // TODO: allow other links facebook, telegram

      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(enterValidLinktext)));
    }

    final _field = TextField(
      controller: mController,
      maxLines: null,
      decoration: InputDecoration(
          labelText: groupLinkText, border: OutlineInputBorder()),
    );
    final _submitButton = Builder(
      builder: (context) {
        return ScopedModelDescendant<MainModel>(
          builder: (_, __, model) {
            return Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    child: model.submittingLinkStatus == StatusCode.waiting
                        ? MyProgressIndicator(color: Colors.white, size: 15.0)
                        : Text(submitText),
                    onPressed: () => _handleSubmitLink(context, model),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(addLinkText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            _field,
            _submitButton,
          ],
        ),
      ),
    );
  }
}

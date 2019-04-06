import 'package:flutter/material.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';
import 'package:linki/src/views/waiting.dart';
import 'dart:math' as math;
import 'package:scoped_model/scoped_model.dart';

const _tag = 'AddLinkDialog:';

class AddLinkDialog extends StatefulWidget {
  @override
  AddLinkDialogState createState() {
    return new AddLinkDialogState();
  }
}

class AddLinkDialogState extends State<AddLinkDialog> {
  final _mController = TextEditingController();
  @override
  void dispose() {
    _mController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) => SimpleDialog(
            title: Text(addLinkText),
            children: model.submittingLinkStatus == StatusCode.waiting
                ? <Widget>[
                    WaitingView(),
                  ]
                : <Widget>[
                    model.linkiError != null
                        ? _buildMessageSection(model)
                        : Container(),
                    _buildTextField(model),
                    _buildActions(model, context),
                  ],
          ),
    );
  }

  _resetField(MainModel model) {
    _mController.text = '';
    model.resetSubmitStatus();
  }

  _buildTextField(MainModel model) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _mController,
        cursorColor: Colors.deepOrange,
        autofocus: true,
        maxLines: null,
        style: TextStyle(
          color: model.submittingLinkStatus == StatusCode.failed
              ? Colors.red
              : Colors.blue,
          decoration: model.submittingLinkStatus == StatusCode.failed
              ? TextDecoration.none
              : TextDecoration.underline,
        ),
        decoration: InputDecoration(
            hintText: model.submittingLinkStatus == StatusCode.failed
                ? errorMessage
                : enterLinkLabelText,
            hintStyle: TextStyle(
              decoration: TextDecoration.none,
            ),
            prefixIcon:
                Transform.rotate(angle: -math.pi / 4, child: Icon(Icons.link)),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () => _resetField(model),
            )),
      ));

  _handleSubmit(MainModel model, BuildContext context) async {
    final url = _mController.text.trim();
    if (url.isEmpty) return null;

    StatusCode submitStatus = await model.submitLink(url, model.currentUser);
    switch (submitStatus) {
      case StatusCode.success:
        Navigator.pop(context);
        break;
      default:
        print('$_tag unexpected submit status code : $submitStatus');
    }
  }

  Widget _buildSubmitButton(MainModel model) => FlatButton(
        child: Text(
          submitText.toUpperCase(),
          style: TextStyle(color: Colors.deepOrange),
        ),
        onPressed: () => _handleSubmit(model, context),
      );

  _buildCancelButton(MainModel model, BuildContext context) => FlatButton(
        child: Text(
          cancelText.toUpperCase(),
        ),
        onPressed: () {
          model.resetSubmitStatus();
          Navigator.pop(context);
        },
      );

  Widget _buildActions(MainModel model, BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _buildSubmitButton(model),
            _buildCancelButton(model, context),
          ],
        ),
      );

  _getErrorMessage(LinkiError type) {
    switch (type) {
      case LinkiError.invalidUrlScheme:
        return invalidUrlErrorMessage;
        break;
      case LinkiError.urlAlreadyExists:
        return duplicateUrlErrorMessage;
        break;
      default:
        print('$_tag uexpected error type: $type');
        return '';
    }
  }

  _buildMessageSection(MainModel model) => Center(
          child: Text(
        _getErrorMessage(model.linkiError),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18.0),
      ));
}

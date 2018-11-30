import 'package:flutter/material.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';
import 'package:linki/src/views/waiting.dart';
import 'dart:math' as math;
import 'package:scoped_model/scoped_model.dart';

const _tag = 'AddLinkDialog:';

class AddLinkDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _mController = TextEditingController();
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
              prefixIcon: Transform.rotate(
                  angle: -math.pi / 4, child: Icon(Icons.link)),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                ),
                onPressed: () => _resetField(model),
              )),
        ));
    _handleSubmit(MainModel model) async {
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
          onPressed: () => _handleSubmit(model),
        );

    _buildCancelButton(MainModel model) => FlatButton(
          child: Text(
            cancelText.toUpperCase(),
          ),
          onPressed: () {
            model.resetSubmitStatus();
            Navigator.pop(context);
          },
        );

    Widget _buildActions(MainModel model) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _buildSubmitButton(model),
              _buildCancelButton(model),
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
                    _buildActions(model),
                  ],
          ),
    );
  }
}

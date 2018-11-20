import 'package:flutter/material.dart';
import 'package:linki/values/strings.dart';
import 'dart:math' as math;

class AddLinkDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _textField = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            cursorColor: Colors.deepOrange,
            autofocus: true,
              maxLines: null,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                // decorationStyle: TextDecorationStyle.dashed
              ),
              decoration: InputDecoration(
                
                  prefixIcon: Transform.rotate(
                      angle: -math.pi / 4, child: Icon(Icons.link)))),
        );

        final _submitButton = FlatButton(child: 
              Text(submitText.toUpperCase(),
              style: TextStyle(
                color: Colors.deepOrange
              ),),
              onPressed: (){},);


      final _cancelButton = FlatButton(
        child: Text(cancelText.toUpperCase(),
        
        ), onPressed: ()=>
        Navigator.pop(context),
      );
        final _actions = Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0
          
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _submitButton,
              _cancelButton,
            ],
          ),
        );

    return SimpleDialog(
      title: Text(addLinkText),
      children: <Widget>[
        _textField,
        _actions,

      ],
    );
  }
}

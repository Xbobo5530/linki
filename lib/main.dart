import 'package:flutter/material.dart';
import 'package:linki/models/main_model.dart';
import 'package:linki/pages/home.dart';
import 'package:linki/values/strings.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(Linki(model: MainModel()));

class Linki extends StatelessWidget {
  final MainModel model;
  Linki({this.model});
  static const primaryColor = Colors.orange;

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(
            //todo work on the app theme data
            primarySwatch: Colors.deepOrange
            // primaryColor: primaryColor,
            // scaffoldBackgroundColor: primaryColor,
            // canvasColor: Colors.black,
            // dialogBackgroundColor: primaryColor,
            // textTheme: Theme.of(context).textTheme.copyWith(
            //       caption: TextStyle(color: Colors.white),
            //       subhead: TextStyle(color: Colors.white),
                // )
                )
                ,
        home: MyHomePage(),
      ),
    );
  }
}

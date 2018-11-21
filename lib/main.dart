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
            primarySwatch: Colors.deepOrange),
        home: MyHomePage(),
      ),
    );
  }
}

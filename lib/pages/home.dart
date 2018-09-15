import 'package:flutter/material.dart';
import 'package:linki/pages/home_page_content.dart';

const APP_NAME = 'Linki';

class Linki extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: APP_NAME,
      theme: new ThemeData(
          primarySwatch: Colors.lightBlue, brightness: Brightness.dark),
      home: new MyHomePage(title: APP_NAME),
    );
  }
}

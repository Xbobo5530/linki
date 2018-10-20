
import 'package:flutter/material.dart';
import 'package:linki/pages/home_page_content.dart';
import 'package:linki/values/strings.dart';



class Linki extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: APP_NAME,
      theme:  ThemeData(
          primarySwatch: Colors.lightBlue, brightness: Brightness.dark),
      home:  MyHomePage(title: APP_NAME),
    );
  }
}
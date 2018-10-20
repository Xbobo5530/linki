import 'package:flutter/material.dart';
import 'package:linki/pages/home_page_content.dart';
import 'package:linki/values/strings.dart';

class Linki extends StatelessWidget {
  static const primaryColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        //todo work on the app theme data
        primaryColor: primaryColor,
        scaffoldBackgroundColor: primaryColor,
      ),
      home: MyHomePage(title: APP_NAME),
    );
  }
}

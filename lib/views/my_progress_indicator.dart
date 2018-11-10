import 'package:flutter/material.dart';

class MyProgressIndicator extends StatelessWidget {
  final Color color;
  final double size;
  MyProgressIndicator({@required this.color, @required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Center(
        child: Theme(
          child: CircularProgressIndicator(),
          data: Theme.of(context).copyWith(accentColor: color),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class helpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Center(
        child: Text(
          'Help content goes here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

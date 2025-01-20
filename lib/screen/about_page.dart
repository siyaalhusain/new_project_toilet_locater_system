import 'package:flutter/material.dart';

class aboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Center(
        child: Text(
          'About content goes here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

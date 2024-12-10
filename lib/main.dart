import 'package:flutter/material.dart';
import 'screen/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  LoginScreen(),
      title: 'PTLR',
      theme: ThemeData(primarySwatch: Colors.blue),

    );
  }
}

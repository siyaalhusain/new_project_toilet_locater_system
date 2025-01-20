import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_x/screen/welcome_screen.dart';  // Welcome screen import
import 'screen/login_page.dart'; // Login page import
import 'screen/home_page.dart'; // HomePage import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(), // Start with WelcomeScreen
      title: 'PTLR',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

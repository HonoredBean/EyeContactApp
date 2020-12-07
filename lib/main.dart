import 'package:flutter/material.dart';
import 'package:eyecontactapp/src/pages/splashScreenPage.dart';

void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye contact',
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
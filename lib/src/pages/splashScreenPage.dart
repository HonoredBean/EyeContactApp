//-----------------------------------------------------------------------------------------
//Importes obtenidos en la paqueteria para obtener las funciones necesarias
//-----------------------------------------------------------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eyecontactapp/src/widgets/splashWidget.dart';
import 'package:eyecontactapp/src/pages/logInPage.dart';
//-----------------------------------------------------------------------------------------
//Importes obtenidos en la paqueteria para obtener las funciones necesarias
//-----------------------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
//-----------------------------------------------------------------------------------------
//Pagina del SplashScreen
//-----------------------------------------------------------------------------------------
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5),() =>
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => LoginPage()
        )
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return splashWidget(context);
  }
}
//-----------------------------------------------------------------------------------------
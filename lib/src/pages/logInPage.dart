import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool bandera = true;
  final LocalAuthentication auth = LocalAuthentication(); 
  @override
  void initState() { 
    super.initState();
    biometrico(context, bandera, auth);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    );
  }
}
//-----------------------------------------------------------------------------------------
//Importes obtenidos en la paqueteria para obtener las funciones necesarias
//-----------------------------------------------------------------------------------------
import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
//-----------------------------------------------------------------------------------------
//Pagina de la autenticacion
//-----------------------------------------------------------------------------------------
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
//-----------------------------------------------------------------------------------------
//Pagina de la autenticacion por huella dactilar
//-----------------------------------------------------------------------------------------
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
    return Container();
  }
}
//-----------------------------------------------------------------------------------------
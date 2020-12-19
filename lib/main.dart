/*
    Asignatura: Inteligencia Artificial
    Unidad:     RNA
    Autores:    Espeleta Mireles Krisan Jared  -  16130802
                Carranco Cataño Alfredo        -  15131297
*/
//-----------------------------------------------------------------------------------------
//Importes obtenidos en la paqueteria para obtener las funciones necesarias
//-----------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:eyecontactapp/src/pages/splashScreenPage.dart';
void main() => runApp(MyApp());
//-----------------------------------------------------------------------------------------
//Ventana principal de la aplicacion, mostrara en seguida el splashscreen del mismo 
//-----------------------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------------------
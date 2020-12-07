import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget splashWidget(BuildContext context){
  return Scaffold(
    body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: titleSplash("Eye contact", Colors.black, 30),
            ),
            Container(
              width: 300,
              height: 300,
              child: Lottie.asset(
                'assets/lottie/visuality.json',
                fit: BoxFit.fill
              ),
            ),
            Expanded(
              child: titleSplash("Inteligencia Artificial", Colors.grey, 20),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget titleSplash(String text, Color colorTexto, double tamTexto){
  return Container(
    padding: EdgeInsets.only(bottom: 10),
    alignment: Alignment.bottomCenter,
    child: Text(
      text,
      style: TextStyle(
        color: colorTexto,
        fontSize: tamTexto,
        fontWeight: FontWeight.bold
      )
    ),
  );
}
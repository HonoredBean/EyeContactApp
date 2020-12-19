//-----------------------------------------------------------------------------------------
//Importes obtenidos en la paqueteria para obtener las funciones necesarias
//-----------------------------------------------------------------------------------------
import 'dart:async';
import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:eyecontactapp/src/widgets/scanWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';
//-----------------------------------------------------------------------------------------
//Pagina de escaneo de texto de la imagen tomada anteriormente, obtendra los parametros:
//file            -> Foto tomada
//selectedScanner -> Validacion
//user            -> Usuario logeado
//-----------------------------------------------------------------------------------------
class ScanPage extends StatefulWidget {
  ScanPage(this.user, this.file, this.selectedScanner);
  final PickedFile file;
  final String selectedScanner;
  final FirebaseUser user;
  @override
  _ScanPageState createState() => _ScanPageState();
}
//-----------------------------------------------------------------------------------------
//Pagina donde mostrara la foto tomada, el texto y la opcion de guardado
//-----------------------------------------------------------------------------------------
class _ScanPageState extends State<ScanPage> {
  FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;
  List<VisionText> currentTextLabels = <VisionText>[];
  Stream sub;
  StreamSubscription<dynamic> subscription;
  @override
  void initState() {
    super.initState();
    sub = new Stream.empty();
    subscription = sub.listen((_) => getImageSize)..onDone(analyzeLabels);
  }
  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }
  //-----------------------------------------------------------------------------------------
  //Metodo donde obtendra la direccion de la fotografia para asi realizar el escaneo
  //-----------------------------------------------------------------------------------------
  void analyzeLabels() async {
    try {
      var currentLabels;
      if (widget.selectedScanner == "TEXT_SCANNER") {
        currentLabels = await textDetector.detectFromPath(widget.file.path);
        if (this.mounted) {
          setState(() {
            currentTextLabels = currentLabels;
          });
        }
      }
    } catch (e) {
      print("MyEx: " + e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Texto escaneado"),
      ),
      body: Column(
        children: <Widget>[
          buildImage(
            widget.file, 
            currentTextLabels, 
            context
          ),
          buildTextList(
            context, 
            currentTextLabels
          ),
        ],
      ),
      floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "ht1",
              backgroundColor: Colors.black45,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.save
                ),
              ),
              onPressed: () => addDoc(context, widget.user, currentTextLabels),
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
          ]
        ),
    );
  }
}
//-----------------------------------------------------------------------------------------
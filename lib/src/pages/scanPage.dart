import 'dart:async';

import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:eyecontactapp/src/widgets/scanWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

class ScanPage extends StatefulWidget {
  ScanPage(this.user, this.file, this.selectedScanner);
  final PickedFile file;
  final String selectedScanner;
  final FirebaseUser user;
  @override
  _ScanPageState createState() => _ScanPageState();
}

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
          RaisedButton.icon(
            onPressed: (){
              addDoc(widget.user, currentTextLabels);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            label: Text("Guardar"),
            icon: Icon(Icons.save),
            color: Colors.lightBlueAccent,
            splashColor: Colors.grey,
          )
        ],
      )
    );
  }
}
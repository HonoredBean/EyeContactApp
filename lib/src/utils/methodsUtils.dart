import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eyecontactapp/src/pages/homePage.dart';
import 'package:eyecontactapp/src/pages/scanPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mlkit/mlkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future <void> biometrico(BuildContext context ,bool bandera, LocalAuthentication auth) async {
  if(bandera){
    bool authenticated = false;
    const androidString = const AndroidAuthMessages(
      cancelButton: "Cancelar",
      goToSettingsButton: "Ajustes",
      signInTitle: "Auntentiquese",
      fingerprintHint: "Toque el sensor",
      fingerprintNotRecognized: "Huella no reconocida",
      fingerprintSuccess: "Huella reconocida",
      goToSettingsDescription: "Por favor configure su huella"
    );
    try {
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: "Auntentiquese para acceder",
        useErrorDialogs: true,
        stickyAuth: true,
        androidAuthStrings: androidString,
      );
      if(!authenticated){
        exit(0);
      }else{
        bandera = false;
        final FirebaseAuth _auth = FirebaseAuth.instance;
        final GoogleSignIn _googleSignIn = new GoogleSignIn();
        signIn(context, _auth, _googleSignIn);
      }
    } catch (e) {
      print(e);
    }
  }
}

void signIn(BuildContext context, FirebaseAuth auth, GoogleSignIn googleSignIn) async{
  GoogleSignInAccount googleUser = await googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final AuthResult authResult = await auth.signInWithCredential(credential);
  FirebaseUser user = authResult.user;
  addUser(user);
  print("signed in " + user.displayName);
  Navigator.pushReplacement(
    context, 
    MaterialPageRoute(
      builder: (context) => HomePage(
        authResult: authResult,
        googleSignIn: googleSignIn,
      )
    )
  );
}

void signOut(GoogleSignIn googleSignIn){
  googleSignIn.signOut().whenComplete(() => SystemChannels.platform.invokeMethod('SystemNavigator.pop'));
}

void signOutReturn(BuildContext context, FirebaseAuth auth, GoogleSignIn googleSignIn){
  googleSignIn.signOut().whenComplete(() => signIn(context, auth, googleSignIn));
}

void onPickImageSelected(BuildContext context, FirebaseUser user, GlobalKey<ScaffoldState> scaffoldKey, String source) async {
  var imageSource;
  if (source == "CAMERA_SOURCE") {
    imageSource = ImageSource.camera;
  } else {
    imageSource = ImageSource.gallery;
  }

  final scaffold = scaffoldKey.currentState;
  final picker = ImagePicker();
  try {
    final file = await picker.getImage(source: imageSource);
    if (file == null) {
      throw Exception('File is not available');
    }
    String _selectedScanner = "TEXT_SCANNER";
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => ScanPage(user, file, _selectedScanner)),
    );
  } catch (e) {
    scaffold.showSnackBar(SnackBar(
      content: Text(e.toString()),
    ));
  }
}

Future<void> addUser(FirebaseUser user) async {
  Map<String, dynamic> map = {"id" : user.uid, "name" : user.displayName, "email" : user.email};
  CollectionReference collectionReference = Firestore.instance.collection('Users');
  QuerySnapshot document = await Firestore.instance.collection('Users').where("email", isEqualTo: user.email).getDocuments();
  var documents = document.documents;
  if (documents.isEmpty) {
    collectionReference.add(map);
  }
}

Future<void> addDoc(BuildContext context, FirebaseUser user, List<VisionText> text) async {
  String salidaTexto = "";
  for (var item in text) {
    salidaTexto += item.text;
    print(item.text);
  }
  Map<String, dynamic> map = {"Texto" : salidaTexto, "Fecha " : DateTime.now(), "name" : user.displayName, "email" : user.email};
  CollectionReference collectionReference = Firestore.instance.collection('FilesByUsers');
  QuerySnapshot document = await Firestore.instance.collection('Users').where("email", isEqualTo: user.email).getDocuments();
  var documents = document.documents;
  if (documents.isNotEmpty) {
    collectionReference.add(map);
  }
  var alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.red,
    ),
  );

  Alert(
    context: context,
    style: alertStyle,
    type: AlertType.success,
    title: "Guardado exitoso",
    desc: "El texto a sido guardado en Firebase",
    buttons: [
      DialogButton(
        child: Text(
          "COOL",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        color: Color.fromRGBO(0, 179, 134, 1.0),
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}

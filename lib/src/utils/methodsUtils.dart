import 'dart:io';

import 'package:eyecontactapp/src/pages/homePage.dart';
import 'package:eyecontactapp/src/pages/scanPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';

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
    /*if(!mounted){
      return; 
    }*/
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
  googleSignIn.signOut().whenComplete(() => exit(0));
}

void onPickImageSelected(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey, String source) async {
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
          builder: (context) => ScanPage(file, _selectedScanner)),
    );
  } catch (e) {
    scaffold.showSnackBar(SnackBar(
      content: Text(e.toString()),
    ));
  }
}
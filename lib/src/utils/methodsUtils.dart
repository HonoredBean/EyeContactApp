/*
    Asignatura: Inteligencia Artificial
    Unidad:     RNA
    Autores:    Espeleta Mireles Krisan Jared  -  16130802
                Carranco Cataño Alfredo        -  15131297
*/
//-----------------------------------------------------------------------------------------
//Importes obtenidos en la paqueteria para obtener las funciones necesarias
//-----------------------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------------------
//Variable para el estilo de las alertas mostradas en la aplicacion
//-----------------------------------------------------------------------------------------
var alertStyle = AlertStyle(
  animationType: AnimationType.fromTop,
  isCloseButton: false,
  isOverlayTapDismiss: false,
  descStyle: TextStyle(fontWeight: FontWeight.bold),
  animationDuration: Duration(milliseconds: 400),
  alertBorder: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0),
    side: BorderSide(
      color: Colors.grey,
    ),
  ),
  titleStyle: TextStyle(
    color: Colors.red,
  ),
);
//-----------------------------------------------------------------------------------------
//Metodo para tomar la lectura de la huella digital registrada en el movil
//-----------------------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------------------
//Metodo para iniciar sesion utilizando la autenticacion en Firebase usando una cuenta 
//asociada a Google
//-----------------------------------------------------------------------------------------
Future<void> signIn(BuildContext context, FirebaseAuth auth, GoogleSignIn googleSignIn) async{
  GoogleSignInAccount googleUser = await googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final AuthResult authResult = await auth.signInWithCredential(credential);
  FirebaseUser user = authResult.user;
  addUser(user);
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
//-----------------------------------------------------------------------------------------
//Metodo para cerrar sesion y cerrar la aplicacion por medio de la invocacion a 
//"SystemNavigator.pop"
//-----------------------------------------------------------------------------------------
void signOut(GoogleSignIn googleSignIn){
  googleSignIn.signOut().whenComplete(() => SystemChannels.platform.invokeMethod('SystemNavigator.pop'));
}
//-----------------------------------------------------------------------------------------
//Metodo para cerrar sesion y cerrar la aplicacion por medio de la invocacion a 
//"SystemNavigator.pop" pero con la diferencia que aun esta dentro de la aplicacion y podra
//iniciar sesion en otra cuenta si asi lo desea el usuario
//-----------------------------------------------------------------------------------------
void signOutReturn(BuildContext context, FirebaseAuth auth, GoogleSignIn googleSignIn){
  googleSignIn.signOut().whenComplete(() => signIn(context, auth, googleSignIn));
}
//-----------------------------------------------------------------------------------------
//Metodo para tomar la fotografia tomada, donde se tendra que validar la existencia de la
//misma y luego mandarla a otra pantalla para realizar el procedimiento de escaneo de texto
//-----------------------------------------------------------------------------------------
void onPickImageSelected(BuildContext context, FirebaseUser user, GlobalKey<ScaffoldState> scaffoldKey, String source) async {
  var imageSource;
  if (source == "CAMERA_SOURCE") {
    imageSource = ImageSource.camera;
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
//-----------------------------------------------------------------------------------------
//Metodo para mostrar la alerta de "Informacion" de la aplicacion
//-----------------------------------------------------------------------------------------
void showInfo(BuildContext context){
  Alert(
    context: context,
    style: alertStyle,
    type: AlertType.info,
    title: "Acerca de",
    desc: "Para agregar fotos a tu Clipboard, presiona el boton con el icono de la camara",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.lightBlue,
        radius: BorderRadius.circular(10),
      ),
    ],
  ).show();
}
//-----------------------------------------------------------------------------------------
//Metodo para agregar un usuario dentro de la BD de Firebase (CloudFirebase) en la cual 
//iria a la coleccion de "Users" tomando un arreglo con su id, nombre y su email. 
//Si este ya se encuentra validado no se registrara nuevamente en la BD
//-----------------------------------------------------------------------------------------
Future<void> addUser(FirebaseUser user) async {
  Map<String, dynamic> map = {"id" : user.uid, "name" : user.displayName, "email" : user.email};
  CollectionReference collectionReference = Firestore.instance.collection('Users');
  QuerySnapshot document = await Firestore.instance.collection('Users').where("email", isEqualTo: user.email).getDocuments();
  var documents = document.documents;
  if (documents.isEmpty) {
    collectionReference.add(map);
  }
}
//-----------------------------------------------------------------------------------------
//Metodo para agregar un documento (Texto escaneado de una foto) a la BD de Firebase 
//(CloudFirebase) donde se asociara a una variable de tipo cadena y esta iria a la
//coleccion "FilesByUsers" donde se registrara por medio de la fecha (Fecha en que se tomo)
//, el nombre del usuario y el email del mismo, para despues mostrar una alerta de guardado
//si la accion fue exitosa 
//-----------------------------------------------------------------------------------------
Future<void> addDoc(BuildContext context, FirebaseUser user, List<VisionText> text) async {
  String salidaTexto = "";
  for (var item in text) {
    salidaTexto += item.text;
    print(item.text);
  }
  Map<String, dynamic> map = {"Texto" : salidaTexto, "Fecha" : DateTime.now(), "name" : user.displayName, "email" : user.email};
  CollectionReference collectionReference = Firestore.instance.collection('FilesByUsers');
  QuerySnapshot document = await Firestore.instance.collection('Users').where("email", isEqualTo: user.email).getDocuments();
  var documents = document.documents;
  if (documents.isNotEmpty) {
    collectionReference.add(map);
    Alert(
      context: context,
      style: alertStyle,
      type: AlertType.success,
      title: "Guardado exitoso",
      desc: "El texto a sido guardado en Firebase",
      buttons: [
        DialogButton(
          child: Text(
            "Gracias",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }
}
//-----------------------------------------------------------------------------------------
//Metodo para convertir la fecha del documento (La cual viene en nano y mili segundos) y 
//este mismo lo regresa en forma de una cadena
//-----------------------------------------------------------------------------------------
String dateTime(DocumentSnapshot document){
  String yy,mm,dd;
  Timestamp time = document["Fecha"];
  DateTime date = time.toDate();
  yy = date.year.toString();
  mm = date.month.toString();
  dd = date.day.toString();
  return yy+"/"+mm+"/"+dd;
}
//-----------------------------------------------------------------------------------------
//Metodo para actualizar el documento (Texto), si este fue modificado por el usuario.
//Este metodo se encargara de mostrar una alerta donde mostrara lo necesario, tambien las
//opciones para el usuario, para actualizar el campo de texto.
//Si se presiona "actualizar" se mandara una solicitud a Firebase para que actualice el
//campo "Texto" y si no es asi solamente se saldra de la alerta
//-----------------------------------------------------------------------------------------
Future<void> updateData(BuildContext context, DocumentSnapshot document) async {
TextEditingController controller = TextEditingController()..text = document["Texto"];
Alert(
    context: context,
    style: alertStyle,
    type: AlertType.warning,
    title: "Realizar cambios?",
    desc: "Selecciona el campo para cambiar el texto",
    content: Column(
      children: [
        Text(
          "Fecha: "+ dateTime(document)
        ),
        TextField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            icon: Icon(Icons.update),
            labelText: "Texto",
          ),
        ),
      ],
    ),
    buttons: [
      DialogButton(
        child: Text(
          "Actualizar",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: (){
          updateText(document["Fecha"], controller);
          Navigator.pop(context);
        },
        color: Color.fromRGBO(0, 179, 134, 1.0),
        radius: BorderRadius.circular(10)
      ),
      DialogButton(
        child: Text(
          "Cancelar",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.red,
        radius: BorderRadius.circular(10)
      ),
    ],
  ).show();
}
//-----------------------------------------------------------------------------------------
//Metodo para actualizar el documento si se presiono el boton de "actualizar" de su 
//respectiva alerta, el cambio se realizara en la coleccion llamada "FilesByUsers"
//-----------------------------------------------------------------------------------------
Future<void> updateText(Timestamp date, TextEditingController controller) async {
  CollectionReference collectionReference = Firestore.instance.collection("FilesByUsers");
  QuerySnapshot querySnapshot = await collectionReference.where("Fecha", isEqualTo: date).getDocuments();
  if(querySnapshot.documents.isNotEmpty){
      querySnapshot.documents[0].reference.updateData({"Texto":controller.text});
  }
}
//-----------------------------------------------------------------------------------------
//Metodo para eliminar el documento (Texto), si el usuario dejo presionado el dedo en una
//tarjeta. Este metodo se encargara de mostrar una alerta donde mostrara lo necesario, 
//tambien las opciones para el usuario, para eliminar el documento.
//Si se presiona "Eliminar" se mandara una solicitud a Firebase para que elimine el 
//documento y si no es asi solamente se saldra de la alerta
//-----------------------------------------------------------------------------------------
Future<void> deleteData(BuildContext context, DocumentSnapshot document) async {
TextEditingController controller = TextEditingController()..text = document["Texto"];
Alert(
    context: context,
    style: alertStyle,
    type: AlertType.error,
    title: "Desea eliminar este documento?",
    content: Column(
      children: [
        Text(
          "Fecha: "+ dateTime(document)
        ),
        TextField(
          controller: controller,
          maxLines: null,
          enabled: false,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            icon: Icon(Icons.update),
            labelText: "Texto",
          ),
        ),
      ],
    ),
    buttons: [
      DialogButton(
        child: Text(
          "Eliminar",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: (){
          deleteText(document["Fecha"], controller);
          Navigator.pop(context);
        },
        color: Color.fromRGBO(0, 179, 134, 1.0),
        radius: BorderRadius.circular(10)
      ),
      DialogButton(
        child: Text(
          "Cancelar",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.red,
        radius: BorderRadius.circular(10)
      ),
    ],
  ).show();
}
//-----------------------------------------------------------------------------------------
//Metodo para eliminar el documento si se presiono el boton de "eliminar" de su 
//respectiva alerta, el cambio se realizara en la coleccion llamada "FilesByUsers"
//-----------------------------------------------------------------------------------------
Future<void> deleteText(Timestamp date, TextEditingController controller) async {
  CollectionReference collectionReference = Firestore.instance.collection("FilesByUsers");
  QuerySnapshot querySnapshot = await collectionReference.where("Fecha", isEqualTo: date).getDocuments();
  if(querySnapshot.documents.isNotEmpty){
      querySnapshot.documents[0].reference.delete();
  }
}
//-----------------------------------------------------------------------------------------
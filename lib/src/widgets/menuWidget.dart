import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Drawer menuDrawer(BuildContext context, AuthResult authResult, GoogleSignIn googleSignIn){
  return Drawer(
    child: Container(
      child: ListView(
        children: [
          basicData(authResult),
          itemList(
            context,
            "MENU", 
            Icon(Icons.menu), 
            googleSignIn, 
            0
          ),
          itemList(
            context,
            "Cambiar de cuenta", 
            Icon(Icons.account_circle), 
            googleSignIn, 
            1
          ),
          itemList(
            context,
            "Salir", 
            Icon(Icons.exit_to_app), 
            googleSignIn, 
            2
          ),
        ],
      ),
    ),
  );
}

Widget basicData(AuthResult authResult){
  return Container(
    color: Colors.black,
    child: UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white30,
        child: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(authResult.user.photoUrl),
        ),
      ),
      accountName: Text(
        authResult.user.displayName, 
        style: TextStyle(
          color: Colors.black, 
          fontWeight: FontWeight.bold
          ),
      ),
      accountEmail: Text(
        authResult.user.email, 
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
      ),
    ),
  );
}

Widget itemList(BuildContext context,String text, Icon icono, GoogleSignIn googleSignIn , int value){
  return ListTile(
    onTap: (){
      switch (value) {
        case 1:
          FirebaseAuth auth = FirebaseAuth.instance;
          signOutReturn(context, auth, googleSignIn);
        break;
        case 2:
          signOut(googleSignIn);
        break;
        default:
      }
    },
    title: Row(
      children: <Widget>[
        icono,
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(text),
        )
      ],
    ),
  );
}
import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MenuWidget extends StatelessWidget {
  MenuWidget(this.authResult, this.googleSignIn);
  final AuthResult authResult;
  final GoogleSignIn googleSignIn;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: [
            Container(
              color: Colors.blue,
              child: UserAccountsDrawerHeader(
                accountName: Text(authResult.user.displayName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                accountEmail: Text(authResult.user.email, style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    alignment: Alignment.centerRight,
                    image: NetworkImage(authResult.user.photoUrl),
                  ),
                ),
              ),
            ),
            Container(
              child: ListTile(
                title: Text("MENU"),
              ),
            ),
            Container(
              child: ListTile(
                title: Text("Salir"),
                onTap: ()=> signOut(googleSignIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
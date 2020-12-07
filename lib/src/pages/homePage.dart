import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.googleSignIn, this.authResult} ): super(key: key);
  final GoogleSignIn googleSignIn;
  final AuthResult authResult;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() { 
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.authResult.user.displayName),
        actions: [
          FloatingActionButton(
            child: CircleAvatar(
              child: Icon(
                Icons.exit_to_app
              ),
            ),
            onPressed: () => signOut(widget.googleSignIn), 
          ),
        ],
      ),
      body: Container(
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black45,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.add_a_photo
          ),
        ),
        onPressed: (){}
      ), 
    );
  }
}
import 'package:eyecontactapp/src/utils/methodsUtils.dart';
import 'package:eyecontactapp/src/widgets/menuWidget.dart';
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() { 
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Bienvenido "+widget.authResult.user.displayName,
            style: TextStyle(
              fontSize: 18
            ),
          ),
        ),
        drawer: menuDrawer(
          context,
          widget.authResult, 
          widget.googleSignIn
        ),
        body: Container(
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "ht2",
              backgroundColor: Colors.black45,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.add_a_photo
                ),
              ),
              onPressed: () => onPickImageSelected(context, scaffoldKey, "CAMERA_SOURCE"),
            ),
          ]
        ), 
      ),
    );
  }
}
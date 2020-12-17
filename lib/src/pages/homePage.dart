import 'package:cloud_firestore/cloud_firestore.dart';
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
        body: StreamBuilder(
          stream: Firestore.instance.collection("FilesByUsers").where("email", isEqualTo: widget.authResult.user.email).snapshots(),
          builder: (context,AsyncSnapshot<QuerySnapshot>snapshot){
            if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            }
            return ListView(
              padding: EdgeInsets.all(10),
              children: snapshot.data.documents.map((document){
                return InkWell(
                  onTap: (){
                    updateData(context, document);
                  },
                  onLongPress: (){
                    deleteData(context, document);
                  },
                  child: Card(
                    color: Colors.lightBlue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/img/picTake.png')
                                )
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    "Fecha: "+dateTime(document),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                    child: Text(
                                      "Texto: \n"+document["Texto"], 
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,        
                                      maxLines: 6,                             
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
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
                  Icons.add_a_photo
                ),
              ),
              onPressed: () => onPickImageSelected(context, widget.authResult.user, scaffoldKey, "CAMERA_SOURCE"),
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
          ]
        ), 
      ),
    );
  }
}
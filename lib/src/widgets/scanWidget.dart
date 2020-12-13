import 'dart:async';
import 'dart:io';

import 'package:eyecontactapp/src/class/textClass.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

Widget buildTextList(BuildContext context, List<VisionText> texts) {
  if (texts.length == 0) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Text(
          "No hay texto valido",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
  return Expanded(
    child: Container(
      child: ListView.builder(
        itemCount: texts.length,
        itemBuilder: (context, i) {
          return buildTextRow(texts[i].text);
        }
      ),
    ),
  );
}

Widget buildTextRow(text) {
  return ListTile(
    title: Text(
      text,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold
      ),
    ),
    dense: true,
  );
}

Widget buildImage(PickedFile file, List<VisionText> currentTextLabels, BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height/2,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(color: Colors.black),
    child: Center(
      child: file == null ? Text('No Image') : FutureBuilder<Size>(
        future: getImageSize(
          Image.file(
            File(file.path), 
            fit: BoxFit.cover
          )
        ),
        builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
          if (snapshot.hasData) {
            return Container(
              foregroundDecoration: TextDetectDecoration(
                currentTextLabels, 
                snapshot.data
              ),
              child: Image.file(
                File(file.path), 
                fit: BoxFit.cover
              )
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    )
  );
}
Future<Size> getImageSize(Image image) {
  Completer<Size> completer = Completer<Size>();
  image.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
      (ImageInfo info, bool _) => completer.complete(
        Size(
          info.image.width.toDouble(), 
          info.image.height.toDouble()
        )
      )
    )
  );
  return completer.future;
}
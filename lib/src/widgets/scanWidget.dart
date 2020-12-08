import 'dart:async';
import 'dart:io';

import 'package:eyecontactapp/src/class/textClass.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

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

Widget buildTextList(BuildContext context, List<VisionText> texts) {
  if (texts.length == 0) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Text(
          'No text detected',
          style: Theme.of(context).textTheme.subtitle1
        ),
      )
    );
  }
  return Expanded(
    flex: 1,
    child: Container(
      child: ListView.builder(
        padding: const EdgeInsets.all(0.5),
        itemCount: texts.length,
        itemBuilder: (context, i) {
          return buildTextRow(texts[i].text);
        }
      ),
    ),
  );
}
Widget buildImage(PickedFile file, List<VisionText> currentTextLabels, BuildContext context) {
  return Expanded(
    flex: 2,
    child: Container(
      decoration: BoxDecoration(color: Colors.black),
      child: Center(
        child: file == null ? Text('No Image') : FutureBuilder<Size>(
          future: getImageSize(
            Image.file(
              File(file.path), 
              fit: BoxFit.fitWidth
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
                  fit: BoxFit.fitWidth
                )
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      )
    ),
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
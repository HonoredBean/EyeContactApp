import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

class ScanPage extends StatefulWidget {
  ScanPage(this.file, this.selectedScanner);
  final PickedFile file;
  final String selectedScanner;

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  FirebaseVisionTextDetector textDetector = FirebaseVisionTextDetector.instance;
  List<VisionText> _currentTextLabels = <VisionText>[];
  Stream sub;
  StreamSubscription<dynamic> subscription;
  @override
  void initState() {
    super.initState();
    sub = new Stream.empty();
    subscription = sub.listen((_) => _getImageSize)..onDone(analyzeLabels);
  }
  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.selectedScanner),
        ),
        body: Column(
          children: <Widget>[
            buildImage(context),
            buildTextList(_currentTextLabels)
          ],
        ));
  }
  Widget _buildTextRow(text) {
    return ListTile(
      title: Text(
        "$text",
      ),
      dense: true,
    );
  }
  Widget buildTextList(List<VisionText> texts) {
    if (texts.length == 0) {
      return Expanded(
          flex: 1,
          child: Center(
            child: Text('No text detected',
                style: Theme.of(context).textTheme.subtitle1),
          ));
    }
    return Expanded(
      flex: 1,
      child: Container(
        child: ListView.builder(
            padding: const EdgeInsets.all(1.0),
            itemCount: texts.length,
            itemBuilder: (context, i) {
              return _buildTextRow(texts[i].text);
            }),
      ),
    );
  }
  Widget buildImage(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
          decoration: BoxDecoration(color: Colors.black),
          child: Center(
            child: widget.file == null
                ? Text('No Image')
                : FutureBuilder<Size>(
                    future: _getImageSize(
                        Image.file(File(widget.file.path), fit: BoxFit.fitWidth)),
                    builder:
                        (BuildContext context, AsyncSnapshot<Size> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                            foregroundDecoration: TextDetectDecoration(
                                    _currentTextLabels, snapshot.data),
                            child:
                                Image.file(File(widget.file.path), fit: BoxFit.fitWidth));
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
          )),
    );
  }
  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()))));
    return completer.future;
  }
  void analyzeLabels() async {
    try {
      var currentLabels;
      if (widget.selectedScanner == "TEXT_SCANNER") {
        currentLabels = await textDetector.detectFromPath(widget.file.path);
        if (this.mounted) {
          setState(() {
            _currentTextLabels = currentLabels;
          });
        }
      }
      } catch (e) {
      print("MyEx: " + e.toString());
    }
  }
}
class TextDetectDecoration extends Decoration {
  final Size _originalImageSize;
  final List<VisionText> _texts;
  TextDetectDecoration(List<VisionText> texts, Size originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return _TextDetectPainter(_texts, _originalImageSize);
  }
}
class _TextDetectPainter extends BoxPainter {
  final List<VisionText> _texts;
  final Size _originalImageSize;
  _TextDetectPainter(texts, originalImageSize)
      : _texts = texts,
        _originalImageSize = originalImageSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final _heightRatio = _originalImageSize.height / configuration.size.height;
    final _widthRatio = _originalImageSize.width / configuration.size.width;
    for (var text in _texts) {
      final _rect = Rect.fromLTRB(
          offset.dx + text.rect.left / _widthRatio,
          offset.dy + text.rect.top / _heightRatio,
          offset.dx + text.rect.right / _widthRatio,
          offset.dy + text.rect.bottom / _heightRatio);
      canvas.drawRect(_rect, paint);
    }
    canvas.restore();
  }
}
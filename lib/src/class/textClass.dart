/*
    Asignatura: Inteligencia Artificial
    Unidad:     RNA
    Autores:    Espeleta Mireles Krisan Jared  -  16130802
                Carranco Cataño Alfredo        -  15131297
*/
//-----------------------------------------------------------------------------------------
//Importes obtenidos en la paqueteria para obtener las funciones necesarias
//-----------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';
//-----------------------------------------------------------------------------------------
//Clase la cual servira para la decoracion del texto escaneado dentro de la foto tomada
//-----------------------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------------------
//Clase que dibujara los recuadros para los textos escaneados, haciendolos vistosos y asi
//notarlos mejor en la foto tomada
//-----------------------------------------------------------------------------------------
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
//-----------------------------------------------------------------------------------------
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerUtils {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    IconData iconData, {
    Color color = Colors.red,
    double size = 120.0,
    double iconSize = 70.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    final Radius radius = Radius.circular(size / 2);

    // Draw the pin shape
    final Path path = Path();
    path.moveTo(size / 2, size);
    path.lineTo(size * 0.2, size * 0.6);
    path.arcToPoint(
      Offset(size * 0.8, size * 0.6),
      radius: radius,
      clockwise: true,
    );
    path.close();
    canvas.drawPath(path, paint);

    // Draw the circle background for the icon
    canvas.drawCircle(
      Offset(size / 2, size * 0.4),
      size * 0.35,
      Paint()..color = Colors.white,
    );

    // Draw the icon
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size / 2 - textPainter.width / 2, size * 0.4 - textPainter.height / 2),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}

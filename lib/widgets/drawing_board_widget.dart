import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

import '../main.dart';

class DrawingBoardWidget extends StatefulWidget {
  const DrawingBoardWidget({super.key});

  @override
  State<DrawingBoardWidget> createState() => _DrawingBoardWidgetState();
}

class _DrawingBoardWidgetState extends State<DrawingBoardWidget> {
  final DrawingController _drawingController = DrawingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DrawingBoard(
        controller: _drawingController,
        background: Container(width: mq.width, color: Colors.white),
        showDefaultActions: true,
        showDefaultTools: true,
      ),
    );
  }

  Future<void> _getImageData() async {
    print((await _drawingController.getImageData())!.buffer.asInt8List());
  }
}

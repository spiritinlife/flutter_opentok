import 'package:flutter/material.dart';

class MoveableStackItem extends StatefulWidget {
  final Widget child;
  final double initXPos;
  final double initYPos;

  const MoveableStackItem({Key key, this.child, this.initXPos = 0, this.initYPos = 0}) : super(key: key);
  @override
  _MoveableStackItemState createState() => _MoveableStackItemState();
}

class _MoveableStackItemState extends State<MoveableStackItem> {
  double xPosition = 0;
  double yPosition = 0;

  @override
  void initState() {
    xPosition = widget.initXPos;
    yPosition = widget.initYPos;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AnimatedPositioned(
        duration: Duration(milliseconds: 10),
        top: yPosition,
        left: xPosition,
        child: GestureDetector(
          onPanUpdate: (tapInfo) {
            setState(
              () {
                xPosition += tapInfo.delta.dx;
                yPosition += tapInfo.delta.dy;
              },
            );
          },
          child: widget.child,
        ),
      );
}

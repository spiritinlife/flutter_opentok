import 'package:flutter/material.dart';
import 'package:flutter_opentok_example/dissapearing_widget.dart';

class ChatFab extends StatelessWidget {
  final String message;
  final VoidCallback onFabClicked;

  const ChatFab({Key key, this.message, this.onFabClicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        message != null
            ? DissapearingWidget(
                duration: Duration(milliseconds: 5000),
                child: ActionChip(
                  label: Text(message),
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: onFabClicked,
                ),
              )
            : SizedBox(),
        FloatingActionButton(
          onPressed: onFabClicked,
          child: Icon(Icons.chat),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_opentok/flutter_opentok.dart';

class ChatScreen extends StatefulWidget {
  final OTFlutter controller;
  final List<Signal> messages;

  final Function(String message) onSendMessage;
  const ChatScreen(
      {Key key, this.messages, this.onSendMessage, this.controller})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Signal> messages = List();
  @override
  void initState() {
    messages = widget.messages;
    widget.controller.signals.addListener(onSignalReceived);
    super.initState();
  }

  void onSignalReceived() {
    messages = widget.controller.signals.signals;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.signals.removeListener(onSignalReceived);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: null,
        backgroundColor: Colors.white.withOpacity(0.6),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView(
                reverse: true,
                children: messages
                    .map(
                      (signal) => ChatMessage(
                        signal: signal,
                      ),
                    )
                    .toList(),
              ),
            ),
            ChatInput(
              onSendMessage: widget.onSendMessage,
            ),
          ],
        ),
      );
}

class ChatMessage extends StatelessWidget {
  final Signal signal;

  const ChatMessage({Key key, this.signal}) : super(key: key);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: signal.isRemote
          ? Row(
              children: [
                CircleAvatar(child: Text("Doc")),
                SizedBox(width: 16),
                Text(
                  signal.data,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  signal.data,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(width: 16),
                CircleAvatar(child: Text("Me")),
              ],
            ));
}

class ChatInput extends StatefulWidget {
  final Function(String message) onSendMessage;

  ChatInput({Key key, this.onSendMessage}) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: null,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    hintText: "Tap to send a message"),
              ),
            ),
            IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (controller.text.isEmpty) return;
                  print("Send message");
                  widget.onSendMessage(controller.text);
                  controller.clear();
                })
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_opentok/flutter_opentok.dart';
import 'package:flutter_opentok_example/chat_fab.dart';
import 'package:flutter_opentok_example/chat_screen.dart';
import 'package:flutter_opentok_example/settings.dart';
import 'package:permission_handler/permission_handler.dart';

import 'movable_stack_item.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _infoStrings = <String>[];
  bool muted = false;
  bool publishVideo = true;
  List<Signal> chatMessages = List();
  OTFlutter controller;
  OpenTokConfiguration openTokConfiguration;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    controller.signals.removeListener(onSignalReceived);
    super.dispose();
  }

  void initialize() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    if (API_KEY.isEmpty) {
      setState(() {
        _infoStrings.add(
            "APP_ID missing, please provide your API_KEY in settings.dart");
        _infoStrings.add("OpenTok is not starting");
      });
      return;
    }

    if (sessionId.isEmpty) {
      setState(() {
        _infoStrings.add(
            "SESSION_ID missing, please provide your SESSION_ID in settings.dart");
        _infoStrings.add("OpenTok is not starting");
      });
      return;
    }

    if (token.isEmpty) {
      setState(() {
        _infoStrings
            .add("TOKEN missing, please provide your TOKEN in settings.dart");
        _infoStrings.add("OpenTok is not starting");
      });
      return;
    }

    openTokConfiguration = OpenTokConfiguration(
      token: token,
      apiKey: API_KEY,
      sessionId: sessionId,
    );

    var publisherSettings = OTPublisherKitSettings(
      name: "Mr. John Doe",
      audioTrack: true,
      videoTrack: publishVideo,
    );

    controller = OTFlutter();
    controller.signals.addListener(onSignalReceived);
    controller.connect(openTokConfiguration, publisherSettings);
  }

  void onSignalReceived() {
    chatMessages = controller.signals.signals;
    setState(() {});
  }

  void goToChatScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return ChatScreen(
              controller: controller,
              messages: chatMessages,
              onSendMessage: (String message) {
                controller.sendSignal(message);
              });
        },
      ),
    );
  }

  // Toolbar layout
  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () => _togglePublisherVideo(),
            child: Icon(
              publishVideo ? Icons.videocam : Icons.videocam_off,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          SizedBox(
            height: 8,
          ),
          RawMaterialButton(
            onPressed: () => _onToggleMute(),
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          SizedBox(
            height: 8,
          ),
          RawMaterialButton(
            onPressed: () => _onSwitchCamera(),
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  void _togglePublisherVideo() async {
    if (publishVideo) {
      controller?.disablePublisherVideo();
    } else {
      controller?.enablePublisherVideo();
    }

    setState(() {
      publishVideo = !publishVideo;
    });
  }

  void _onToggleMute() async {
    if (muted) {
      controller?.unmutePublisherAudio();
    } else {
      controller?.mutePublisherAudio();
    }

    setState(() {
      muted = !muted;
    });
  }

  void _onSwitchCamera() async {
    controller?.switchCamera();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('OpenTok SDK'),
          ),
          backgroundColor: Colors.black,
          floatingActionButton: ChatFab(
            message: chatMessages.firstWhere((signal) => signal.isRemote, orElse: () => null)?.data,
            onFabClicked: goToChatScreen,
          ),
          body: Builder(
            builder: (context) => Container(
              color: Colors.yellow,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(child: SubscriberView(), color: Colors.green),
                  MoveableStackItem(
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      color: Theme.of(context).primaryColor,
                      child: PublisherView(),
                      height: 120,
                      width: 90,
                    ),
                    initXPos: 5,
                    initYPos: 5,
                  ),
                  _toolbar()
                ],
              ),
            ),
          ),
        ),
      );
}

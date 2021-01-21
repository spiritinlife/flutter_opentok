import 'package:flutter/material.dart';
import 'package:flutter_opentok/flutter_opentok.dart';
import 'package:flutter_opentok_example/settings.dart';
import 'package:permission_handler/permission_handler.dart';

import 'movable_stack_item.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _infoStrings = <String>[];
  bool muted = false;
  bool publishVideo = true;
  OTFlutter controller;
  OpenTokConfiguration openTokConfiguration;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
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

    if (SESSION_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
            "SESSION_ID missing, please provide your SESSION_ID in settings.dart");
        _infoStrings.add("OpenTok is not starting");
      });
      return;
    }

    if (TOKEN.isEmpty) {
      setState(() {
        _infoStrings
            .add("TOKEN missing, please provide your TOKEN in settings.dart");
        _infoStrings.add("OpenTok is not starting");
      });
      return;
    }

    openTokConfiguration = OpenTokConfiguration(
      token: TOKEN,
      apiKey: API_KEY,
      sessionId: SESSION_ID,
    );

    var publisherSettings = OTPublisherKitSettings(
      name: "Mr. John Doe",
      audioTrack: true,
      videoTrack: publishVideo,
    );

    controller = OTFlutter();
    controller.connect(openTokConfiguration, publisherSettings);
  }

  // Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.length == 0) {
                return null;
              }
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                        decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
                  _panel(),
                  _toolbar()
                ],
              ),
            ),
          ),
        ),
      );
}

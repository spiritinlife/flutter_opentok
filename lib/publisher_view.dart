import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PublisherView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final key = "OPENTOK_PUBLISHER_VIEW";
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        key: new ObjectKey(key),
        viewType: key,
        creationParamsCodec: StandardMessageCodec(),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        key: new ObjectKey(key),
        viewType: key,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text("Unsupported device");
  }
}

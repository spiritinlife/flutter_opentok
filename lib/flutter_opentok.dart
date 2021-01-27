import 'dart:convert';
import 'package:flutter_opentok/signal.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
export 'publisher_view.dart';
export 'subscriber_view.dart';
export 'signal.dart';
import 'signals.dart';

part 'flutter_opentok.g.dart';

class OTFlutter {
  static bool loggingEnabled = true;

  OTFlutter()
      : _channel = MethodChannel("plugins.indoor.solutions/opentok"),
        _eventChannel =
            new EventChannel('plugins.indoor.solutions/opentok_messages') {
    _channel.setMethodCallHandler(_handleMethodCall);
    _eventChannel.receiveBroadcastStream().listen(onSignalEvent);
  }

  final Signals signals = Signals();
  final MethodChannel _channel;
  final EventChannel _eventChannel;

  // Core Events

  /// Triggered before creating OpenTok session.
  List<Function(Signal signal)> onSignalListeners = List();

  /// Triggered before creating OpenTok session.
  static VoidCallback onWillConnect;

  /// Occurs when the client connects to the OpenTok session.
  static VoidCallback onSessionConnect;

  /// Occurs when the client disconnects from the OpenTok session.
  static VoidCallback onSessionDisconnect;

  /// Occurs when the subscriber video is added to renderer.
  static VoidCallback onReceiveVideo;

  /// Occurs when subscriber stream has been created.
  static VoidCallback onCreateStream;

  /// Occurs when publisher stream has been created.
  static VoidCallback onCreatePublisherStream;

  void onSignalEvent(dynamic signal) {
    print("notify ${onSignalListeners.length} listeners");
    signals.addSignal(Signal.fromMap(signal));
  }

  // Core Methods
  /// Creates an OpenTok instance.
  ///
  /// The OpenTok SDK only supports one instance at a time, therefore the app should create one object only.
  /// Only users with the same api key, session id and token can join the same _channel and call each other.
  Future<void> connect(OpenTokConfiguration configuration,
      OTPublisherKitSettings publisherKitSettings) async {
    return await _channel.invokeMethod('connect', {
      'apiKey': configuration.apiKey,
      'sessionId': configuration.sessionId,
      'token': configuration.token,
      'publisherSettings': publisherKitSettings.toJson(),
    });
  }

  /// Destroys the instance and releases all resources used by the OpenTok SDK.
  ///
  /// This method is useful for apps that occasionally make voice or video calls, to free up resources for other operations when not making calls.
  /// Once the app calls destroy to destroy the created instance, you cannot use any method or callback in the SDK.
  Future<void> destroy() async {
    _removeMethodCallHandler();
    return await _channel.invokeMethod('destroy');
  }

  // Core Audio
  /// Enables the audio module.
  ///
  /// The audio module is enabled by default.
  Future<void> enableAudio() async {
    await _channel.invokeMethod('enableAudio');
  }

  /// Disables the audio module.
  ///
  /// The audio module is enabled by default.
  Future<void> disableAudio() async {
    await _channel.invokeMethod('disableAudio');
  }

  /// Unmute the publisher audio module.
  ///
  /// The audio module is enabled by default.
  Future<void> unmutePublisherAudio() async {
    await _channel.invokeMethod('unmutePublisherAudio');
  }

  /// Mute the publisher audio module.
  ///
  /// The audio module is enabled by default.
  Future<void> mutePublisherAudio() async {
    await _channel.invokeMethod('mutePublisherAudio');
  }

  /// Enables the subscriber video module.
  ///
  /// The audio module is enabled by default.
  Future<void> enablePublisherVideo() async {
    await _channel.invokeMethod('enablePublisherVideo');
  }

  /// Disables the publishers video module.
  ///
  /// The audio module is enabled by default.
  Future<void> disablePublisherVideo() async {
    await _channel.invokeMethod('disablePublisherVideo');
  }

  /// Disables the subscribers audio.
  Future<void> muteSubscriberAudio() async {
    await _channel.invokeMethod('muteSubscriberAudio');
  }

  /// Enables the subscribers audio.
  Future<void> unmuteSubscriberAudio() async {
    await _channel.invokeMethod('unmuteSubscriberAudio');
  }

  // Disconnects the publisher.
  Future<void> disconnectPublisher() async {
    await _channel.invokeMethod('disconnectPublisher');
  }

  // Reconnects the publisher.
  Future<void> reconnectPublisher() async {
    //await _channel.invokeMethod('reconnectPublisher');
    await _channel.invokeMethod('connect');
  }

  // Core Video
  /// Enables the video module.
  ///
  /// You can call this method either before or after [joinChannel]. If you call this method before joining a _channel, the service starts in the video mode. If you call this method during an audio call, the audio mode switches to the video mode.
  /// To disable the video, call the [disableVideo] method.
  /// This method affects the internal engine and can be called after calling the [leaveChannel] method.
  Future<void> enableVideo() async {
    await _channel.invokeMethod('enableVideo');
  }

  /// Disables the video module.
  ///
  /// You can call this method either before or after [joinChannel]. If you call this method before joining a _channel, the service starts in audio mode. If you call this method during a video call, the video mode switches to the audio mode.
  /// To enable the video mode, call the [enableVideo] method.
  /// This method affects the internal engine and can be called after calling the [leaveChannel] method.
  Future<void> disableVideo() async {
    await _channel.invokeMethod('disableVideo');
  }

  // Camera Control
  /// Switches between front and rear cameras.
  Future<void> switchCamera() async {
    await _channel.invokeMethod('switchCamera');
  }

  // Camera Control
  /// Switches between front and rear cameras.
  Future<void> sendSignal(String message, {String type = ''}) async {
    await _channel.invokeMethod('sendSignal', {
      'message': message,
      'type': type,
    });
  }

  // Miscellaneous Methods
  /// Gets the SDK version.
  Future<String> getSdkVersion() async {
    final String version = await _channel.invokeMethod('getSdkVersion');
    return version;
  }

  // CallHandler
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    Map values = call.arguments;

    switch (call.method) {
      case 'onSessionConnect':
        if (onSessionConnect != null) {
          onSessionConnect();
        }
        break;

      case 'onSessionDisconnect':
        if (onSessionDisconnect != null) {
          onSessionDisconnect();
        }
        break;

      case 'onReceiveVideo':
        if (onReceiveVideo != null) {
          onReceiveVideo();
        }
        break;

      case 'onCreateStream':
        if (onCreateStream != null) {
          onCreateStream();
        }
        break;

      case 'onCreatePublisherStream':
        if (onCreatePublisherStream != null) {
          onCreatePublisherStream();
        }
        break;

      case 'onWillConnect':
        if (onWillConnect != null) {
          onWillConnect();
        }
        break;

      default:
        throw MissingPluginException();
    }
  }

  void _removeMethodCallHandler() {
    _channel.setMethodCallHandler(null);
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

const int OpenTokVideoBitrateStandard = 0;
const int OpenTokVideoBitrateCompatible = -1;

@JsonSerializable()
class OpenTokConfiguration {
  /// The token generated for this connection.
  final String token;

  /// Your OpenTok API key.
  final String apiKey;

  /// The [session ID](http://tokbox.com/opentok/tutorials/create-session)
  /// of this instance. This is an immutable value.
  final String sessionId;

  OpenTokConfiguration({this.token, this.apiKey, this.sessionId});

  factory OpenTokConfiguration.fromJson(Map<String, dynamic> json) =>
      _$OpenTokConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$OpenTokConfigurationToJson(this);
}

/// Note that in sessions that use the OpenTok Media Router (sessions with the
/// [media mode](http://tokbox.com/opentok/tutorials/create-session/#media-mode)
/// set to routed), lowering the frame rate proportionally reduces the bandwidth
/// the stream uses. However, in sessions that have the media mode set to
/// relayed, lowering the frame rate does not reduce the stream's bandwidth.
enum OTCameraCaptureFrameRate {
  /// 30 frames per second.
  OTCameraCaptureFrameRate30FPS,

  /// 15 frames per second.
  OTCameraCaptureFrameRate15FPS,

  /// 7 frames per second.
  OTCameraCaptureFrameRate7FPS,

  /// 1 frame per second.
  OTCameraCaptureFrameRate1FPS,
}

enum OTCameraCaptureResolution {
  /// The lowest available camera capture resolution supported in the OpenTok iOS SDK (352x288)
  /// or the closest resolution supported on the device.
  OTCameraCaptureResolutionLow,

  /// VGA resolution (640x480) or the closest resolution supported on the device.
  ///
  /// AVCaptureSessionPreset640x480
  OTCameraCaptureResolutionMedium,

  /// The highest available camera capture resolution supported in the OpenTok iOS SDK
  /// (1280x720) or the closest resolution supported on the device.
  ///
  /// AVCaptureSessionPreset1280x720
  OTCameraCaptureResolutionHigh,
}

/// OpenTokAudioBitrateDefault default value is 40,000.
const int OpenTokAudioBitrateDefault = 400000;

/// OTPublisherKitSettings defines settings to be used when initializing a publisher.
@JsonSerializable()
class OTPublisherKitSettings {
  const OTPublisherKitSettings({
    this.name,
    this.audioTrack,
    this.videoTrack,
    this.audioBitrate,
    this.cameraResolution,
    this.cameraFrameRate,
  });

  /// The name of the publisher video. The <[OTStream name]> property
  /// for a stream published by this publisher will be set to this value
  /// (on all clients). The default value is `null`.
  final String name;

  /// Whether to publish audio (YES, the default) or not (NO).
  /// If this property is set to NO, the audio subsystem will not be initialized
  /// for the publisher, and setting the <[OTPublisherKit publishAudio]> property
  /// will have no effect. If your application does not require the use of audio,
  /// it is recommended to set this Builder property rather than use the
  /// <[OTPublisherKit publishAudio]> property, which only temporarily disables
  /// the audio track.
  final bool audioTrack;

  /// Whether to publish video (YES, the default) or not (NO).
  /// If this property is set to NO, the video subsystem will not be initialized
  /// for the publisher, and setting the <[OTPublisherKit publishVideo]> property
  /// will have no effect. If your application does not require the use of video,
  /// it is recommended to set this Builder property rather than use the
  /// <[OTPublisherKit publishVideo]> property, which only temporarily disables
  /// the video track.
  final bool videoTrack;

  /// The desired bitrate for the published audio, in bits per second.
  /// The supported range of values is 6,000 - 510,000. (Invalid values are
  /// ignored.) Set this value to enable high-quality audio (or to reduce
  /// bandwidth usage with lower-quality audio).
  ///
  /// The following are recommended settings:
  ///
  /// 8,000 - 12,000 for narrowband (NB) speech
  /// 16,000 - 20,000 for wideband (WB) speech
  /// 28,000 - 40,000 for full-band (FB) speech
  /// 48,000 - 64,000 for full-band (FB) mono music
  /// 64,000 - 128,000 for full-band (FB) stereo music
  ///
  /// The default value is [OpenTokAudioBitrateDefault].
  final int audioBitrate;

  final OTCameraCaptureResolution cameraResolution;

  final OTCameraCaptureFrameRate cameraFrameRate;

  factory OTPublisherKitSettings.fromJson(Map<String, dynamic> json) =>
      _$OTPublisherKitSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$OTPublisherKitSettingsToJson(this);
}

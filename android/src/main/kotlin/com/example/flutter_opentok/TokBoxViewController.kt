package com.example.flutter_opentok

import android.content.Context
import android.graphics.Color
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TokBoxViewController(
        private val context: Context,
        messenger: BinaryMessenger
) : VoIPProviderDelegate, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    val publisherView: FrameLayout;
    val subsciberView: FrameLayout;
    private val provider: OpenTokVoIPImpl = OpenTokVoIPImpl(context, this)
    private var signalEventsSink: EventChannel.EventSink? = null

    init {
        MethodChannel(messenger, "plugins.indoor.solutions/opentok").setMethodCallHandler(this)
        EventChannel(messenger, "plugins.indoor.solutions/opentok_messages").setStreamHandler(this)

        publisherView = FrameLayout(context)
        subsciberView = FrameLayout(context)
    }

    fun disposePublisher() {
        provider.disconnect()
    }

    fun dispose() {
        provider.disconnect()
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "connect" -> {
                provider.connect(
                        methodCall.argument<String>("apiKey")!!,
                        methodCall.argument<String>("sessionId")!!,
                        methodCall.argument<String>("token")!!,
                        PublisherSettings.fromMap(methodCall.argument("publisherSettings")!!)
                )
            }
            "destroy" -> provider.disconnect()
            "enablePublisherVideo" -> provider.enablePublisherVideo()
            "disablePublisherVideo" -> provider.disablePublisherVideo()
            "unmutePublisherAudio" -> provider.unmutePublisherAudio()
            "mutePublisherAudio" -> provider.mutePublisherAudio()
            "muteSubscriberAudio" -> provider.muteSubscriberAudio()
            "unmuteSubscriberAudio" -> provider.unmuteSubscriberAudio()
            "sendSignal" -> provider.sendMessage(
                    methodCall.argument<String>("message")!!,
                    methodCall.argument<String>("type") ?: ""
            )
            "switchCamera" -> provider.switchCamera()
//            "switchAudioToSpeaker" -> provider.switchAudioToSpeaker()
//            "switchAudioToReceiver" -> provider.switchAudioToReceiver()
//
//            "onCallDispose" -> setOnCallDisposeResult(result)
            else -> result.notImplemented()
        }
    }


    override fun willConnect() {
    }

    override fun didConnect() {
    }

    override fun didDisconnect() {
    }

    override fun didReceiveVideo() {

    }

    override fun didCreateStream() {
        subsciberView.addView(provider.subscriberView)
    }

    override fun didCreatePublisherStream() {
        publisherView.addView(provider.publisherView)
    }

    override fun onSignalReceived(remote: Boolean, type: String?, data: String?) {
        signalEventsSink?.success(Signal(remote, type, data).toMap())
    }

    fun initializePublisherView(args: Map<String, String>) {
        provider.initializePublisherView(args);
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        signalEventsSink = events!!;
    }

    override fun onCancel(arguments: Any?) {
        signalEventsSink = null
    }


}


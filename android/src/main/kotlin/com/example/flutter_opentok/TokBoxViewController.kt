package com.example.flutter_opentok

import android.content.Context
import android.graphics.Color
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TokBoxViewController(
        private val context: Context,
        messenger: BinaryMessenger
) : VoIPProviderDelegate, MethodChannel.MethodCallHandler {

    val publisherView: FrameLayout;
    val subsciberView: FrameLayout;
    private val provider: OpenTokVoIPImpl = OpenTokVoIPImpl(context, this)

    init {
        MethodChannel(messenger, "plugins.indoor.solutions/opentok").setMethodCallHandler(this)

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
            "sendMessage" -> provider.sendMessage(
                    methodCall.argument<String>("message")!!,
                    methodCall.argument<String>("type")!!
            )
            "switchCamera" -> provider.switchCamera()
//            "switchAudioToSpeaker" -> provider.switchAudioToSpeaker()
//            "switchAudioToReceiver" -> provider.switchAudioToReceiver()
//
//            "onCallDispose" -> setOnCallDisposeResult(result)
//            "sendMessage" -> tokboxView.sendMessage(methodCall.argument<String>("message"))
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

    fun initializePublisherView(args: Map<String, String>) {
        provider.initializePublisherView(args);
    }

}


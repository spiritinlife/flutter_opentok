package com.example.flutter_opentok

import android.Manifest
import android.content.Context
import android.opengl.GLSurfaceView
import android.util.Log
import android.view.View
import com.opentok.android.*
import pub.devrel.easypermissions.EasyPermissions


interface VoIPProviderDelegate {
    fun willConnect()
    fun didConnect()
    fun didDisconnect()
    fun didReceiveVideo()
    fun didCreateStream()
    fun didCreatePublisherStream()
}

public interface VoIPProvider {

    /// Whether VoIP connection has been established.
    var isConnected: Boolean

    // Set whether publisher has audio or not.
    var isAudioOnly: Boolean

    fun connect(apiKey: String, sessionId: String, token: String, publisherSettings: PublisherSettings)
    fun disconnect()
    fun sendMessage(message: String, type: String)

    fun mutePublisherAudio()
    fun unmutePublisherAudio()

    fun muteSubscriberAudio()
    fun unmuteSubscriberAudio()

    fun enablePublisherVideo()
    fun disablePublisherVideo()
}

class OpenTokVoIPImpl(private val context: Context, private val delegate: VoIPProviderDelegate) : VoIPProvider, Session.SessionListener, SubscriberKit.SubscriberListener, PublisherKit.PublisherListener {

    val subscriberView: View?
        get() = subscriber?.view

    val publisherView: View?
        get() = publisher?.view

    private lateinit var session: Session
    private var publisher: Publisher? = null
    private var subscriber: Subscriber? = null

    private lateinit var publisherSettings: PublisherSettings

    var publishVideo: Boolean = false
        set(value) {
            field = value
            publisher?.publishVideo = field
        }

    override var isConnected: Boolean
        get() = session.connection != null
        set(value) {}

    override var isAudioOnly: Boolean
        get() = !publishVideo
        set(value) {}

    override fun connect(apiKey: String, sessionId: String, token: String, publisherSettings: PublisherSettings) {
        this.publisherSettings = publisherSettings
        val perms = arrayOf(Manifest.permission.INTERNET, Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
        if (EasyPermissions.hasPermissions(context, *perms)) {
            delegate.willConnect()
            createSession(apiKey, sessionId, token)
        }
    }

    override fun disconnect() {
        disconnectSession()
    }

    override fun sendMessage(message: String, type: String) {
        session.sendSignal(type, message)
    }

    override fun mutePublisherAudio() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] Mute publisher audio")
        }

        publisher?.publishAudio = false
    }

    override fun unmutePublisherAudio() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] UnMute publisher audio")
        }

        publisher?.publishAudio = true
    }

    override fun muteSubscriberAudio() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] Mute subscriber audio")
        }

        subscriber?.subscribeToAudio = false
    }

    override fun unmuteSubscriberAudio() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] UnMute subscriber audio")
        }

        subscriber?.subscribeToAudio = true
    }

    override fun enablePublisherVideo() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl]  Enable publisher video")
        }

        publisher?.publishVideo = true
    }

    override fun disablePublisherVideo() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl]  Disable publisher video")
        }

        publisher?.publishVideo = false
    }


    private fun createSession(key: String, sessionId: String, token: String) {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] Create OTSession")
            Log.d("OpenTok", "[OpenTokVoIPImpl] API key: $key")
            Log.d("OpenTok", "[OpenTokVoIPImpl] Session ID: $sessionId")
            Log.d("OpenTok", "[OpenTokVoIPImpl] Token: $token")
        }

        if (key == "" || sessionId == "" || token == "") {
            return
        }

        session = Session.Builder(context, key, sessionId).build()
        session.setSessionListener(this);
        session.connect(token)
    }

    private fun disconnectSession() {
        session.disconnect()
    }

    private fun publish() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] Publish")
        }

        publisher = Publisher.Builder(context)
                .name(publisherSettings.name)
                .videoTrack(publisherSettings.videoTrack)
                .audioTrack(publisherSettings.audioTrack)
                .resolution(Publisher.CameraCaptureResolution.HIGH)
                .frameRate(Publisher.CameraCaptureFrameRate.FPS_30)
                .build()

        publisher?.renderer?.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE,
                BaseVideoRenderer.STYLE_VIDEO_FILL);

        publisher?.setPublisherListener(this)

        if (publisher?.view is GLSurfaceView) {
            (publisher?.view as GLSurfaceView).setZOrderOnTop(true)
        }
        session.publish(publisher)
    }

    private fun unpublish() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] Unpublish")
        }

        session.unpublish(publisher)
    }

    private fun subscribe(stream: Stream?) {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] Subscribe to stream ${stream?.name}")
        }

        subscriber = Subscriber.Builder(context, stream).build()

        subscriber?.renderer?.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE,
                BaseVideoRenderer.STYLE_VIDEO_FILL);

        subscriber?.setSubscriberListener(this)
        session.subscribe(subscriber)
    }

    private fun unsubscribe() {
        if (FlutterOpentokPlugin.loggingEnabled) {
            Log.d("OpenTok", "[OpenTokVoIPImpl] Unsubscribe")
        }

        session.unsubscribe(subscriber)

    }

    // session connected and we can start publishing
    override fun onConnected(session: Session) {
        publish()
        delegate.didConnect()
    }

    override fun onDisconnected(p0: Session?) {
        unsubscribe()
        unpublish()
        delegate.didDisconnect()
    }

    override fun onStreamReceived(session: Session?, stream: Stream?) {
        subscribe(stream)
        delegate.didCreateStream()
    }

    override fun onStreamDropped(p0: Session?, p1: Stream?) {
    }

    override fun onError(p0: Session?, p1: OpentokError?) {
    }

    override fun onConnected(p0: SubscriberKit?) {
    }

    override fun onDisconnected(p0: SubscriberKit?) {
        unpublish()
    }

    override fun onError(p0: SubscriberKit?, p1: OpentokError?) {
        Log.d("OpenTok", "[SubscriberKit] " + p1.toString())
    }

    override fun onStreamCreated(p0: PublisherKit?, p1: Stream?) {
        delegate.didCreatePublisherStream()
    }

    override fun onStreamDestroyed(p0: PublisherKit?, p1: Stream?) {
        unsubscribe()
    }

    override fun onError(p0: PublisherKit?, p1: OpentokError?) {
        Log.d("OpenTok", "[PublisherKit] " + p1.toString())
    }

    fun initializePublisherView(args: Map<String, String>) {

    }

    fun switchCamera() {
        publisher?.cycleCamera()
    }
}
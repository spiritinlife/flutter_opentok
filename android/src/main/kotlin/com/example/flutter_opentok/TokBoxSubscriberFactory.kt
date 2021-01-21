package com.example.flutter_opentok;

import android.content.Context

import io.flutter.plugin.common.*
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import android.util.Log


class TokBoxSubscriberFactory(private val controller: TokBoxViewController) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return TokBoxSubscriberView(controller);
    }
}
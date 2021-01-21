package com.example.flutter_opentok

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class TokBoxSubscriberView (var controller: TokBoxViewController) : PlatformView {

    override fun getView(): View {
        return controller.subsciberView
    }

    override fun dispose() {
        controller.dispose()
    }

}
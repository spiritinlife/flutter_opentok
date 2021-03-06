package com.example.flutter_opentok

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** TokboxPlugin */
class FlutterOpentokPlugin: FlutterPlugin {

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    controller = TokBoxViewController(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger)

    flutterPluginBinding.platformViewRegistry
            .registerViewFactory(TokBoxConfig.PUBLISHER_VIEW, TokBoxPublisherFactory(controller))
    flutterPluginBinding.platformViewRegistry
            .registerViewFactory(TokBoxConfig.SUBSCRIBER_VIEW, TokBoxSubscriberFactory(controller))
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {

    const val loggingEnabled = true

    private lateinit var controller: TokBoxViewController

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      controller = TokBoxViewController(registrar.context(), registrar.messenger())

      registrar.platformViewRegistry()
              .registerViewFactory(TokBoxConfig.PUBLISHER_VIEW, TokBoxPublisherFactory(controller))
      registrar.platformViewRegistry()
              .registerViewFactory(TokBoxConfig.SUBSCRIBER_VIEW, TokBoxSubscriberFactory(controller))
    }
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}

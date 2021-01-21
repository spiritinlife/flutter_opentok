package com.example.flutter_opentok
import android.util.Log

class PublisherSettings(val name: String, val audioTrack: Boolean, val videoTrack: Boolean) {

    companion object {
        fun fromMap(attrs: Map<String, Any>): PublisherSettings {
            Log.e("DLMEDW", attrs.toString());
            return PublisherSettings(
                    attrs["name"]?.toString() ?: error("No name given"),
                    attrs["audioTrack"]?.toString()?.toBoolean() ?: true,
                    attrs["videoTrack"]?.toString()?.toBoolean() ?: true
            )
        }
    }
}
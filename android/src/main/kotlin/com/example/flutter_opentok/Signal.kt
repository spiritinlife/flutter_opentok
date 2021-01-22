package com.example.flutter_opentok

class Signal(val remote: Boolean, val type: String?, val data: String?) {
    fun toMap(): Map<String, Any?>  {
        return mapOf( "isRemote" to remote, "type" to type, "data" to data)
    }
}
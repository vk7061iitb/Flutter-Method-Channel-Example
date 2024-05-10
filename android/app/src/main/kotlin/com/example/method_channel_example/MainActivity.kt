package com.example.method_channel_example

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val methodChannelName  = "com.app_blocker/method"
    private val lightChannelName = "com.app_blocker/light"

    private var methodChannel:MethodChannel ?= null
    private lateinit var sensorManager:SensorManager

    private var lightChannel:EventChannel ?= null
    private var lightStreamHandler:StreamHandler ?= null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Channel
        setupChannels(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        teardownChannels()
        super.onDestroy()
    }

    private fun setupChannels(context: Context, messenger: BinaryMessenger) {
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        methodChannel = MethodChannel(messenger, methodChannelName)
        methodChannel!!.setMethodCallHandler { call,result ->
            if(call.method == "isSensorAvailable"){
                result.success(sensorManager.getSensorList(Sensor.TYPE_LIGHT).isNotEmpty())
            } else{
                result.notImplemented()
            }
        }

        lightChannel = EventChannel(messenger, lightChannelName)
        lightStreamHandler = StreamHandler(sensorManager, Sensor.TYPE_LIGHT)
        lightChannel!!.setStreamHandler(lightStreamHandler)
    }

    private fun teardownChannels() {
        methodChannel!!.setMethodCallHandler(null)
        lightChannel!!.setStreamHandler(null)
    }

}

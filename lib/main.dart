import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Light Sensor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MethodChannel _methodChannel =
      const MethodChannel("com.app_blocker/method");
  final EventChannel _pressureChannel =
      const EventChannel("com.app_blocker/light");

  late String _sensorAvailable;
  late double _lightReading;
  late StreamSubscription _lightSubscription;

  @override
  void initState() {
    super.initState();
    _sensorAvailable = 'Unknown';
    _lightReading = 0.0;
  }

  @override
  void dispose() {
    _lightSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    try {
      final available =
          await _methodChannel.invokeMethod<bool>('isSensorAvailable');
      setState(() {
        _sensorAvailable = available.toString();
      });
    } on PlatformException catch (error) {
      if (error.code == 'UNAVAILABLE') {
        setState(() {
          _sensorAvailable = 'Not Available';
        });
      }
    }
  }

  void _startReading() {
    _lightSubscription = _pressureChannel
        .receiveBroadcastStream()
        .cast<double>()
        .listen((event) {
      setState(() {
        _lightReading = event;
      });
    });
  }

  void _stopReading() {
    setState(() {
      _lightReading = 0.0;
    });
    _lightSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Sensor App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _checkAvailability,
                      child: const Text('Sensor Available'),
                    ),
                    const SizedBox(height: 16.0),
                    Text(_sensorAvailable),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sensor Value"),
                    Text(_lightReading.toStringAsFixed(4))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _startReading,
              child: const Text('Start Sensor Reading'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _stopReading,
              child: const Text('Stop Sensor Reading'),
            ),
          ],
        ),
      ),
    );
  }
}

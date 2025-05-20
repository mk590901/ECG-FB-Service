import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:math';

import 'data_holder.dart';
import 'ecg_simulator/ecg_simulator.dart';

// Initialize the foreground service
Future<void> initializeForegroundService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription: 'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.DEFAULT,
      priority: NotificationPriority.DEFAULT,
      enableVibration: false,
      playSound: false,
      showWhen: false,
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 1000, // Run every 5 seconds
      autoRunOnBoot: false,
      allowWifiLock: true,
    ),
  );
}

// Task handler for the foreground service
class ServiceTaskHandler extends TaskHandler {
  int counter = 0;
  final Random random = Random();
  final EcgSimulator ecgSimulator = EcgSimulator(128);
  SendPort? _sendPort;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    print('Foreground service started');
    // Send initial data
    _sendPort?.send({
      'counter': counter,
      'numbers': [],
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    counter++;
    List<double> numbers = ecgSimulator.generateECGData();
    //@print('Foreground service running: $counter, numbers: ${numbers.length}');
    // Update notification
    await FlutterForegroundTask.updateService(
      foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000,),
      notificationTitle: 'Foreground Service',
      notificationText: '${DateTime.now()}\ncounter: $counter',
      //notificationText: 'Counter: $counter, Numbers: ${numbers.map((n) => n.toStringAsFixed(2)).join(', ')}',
      // notificationIcon: NotificationIconData(
      //   resType: ResourceType.mipmap,
      //   resPrefix: ResourcePrefix.ic,
      //   name: 'com.example.flutter_fb_task.HEART_ICON',
      //   backgroundColor: Color(0xFF202020),
      // ),
    );

    // Send data to app
    sendPort?.send({
      'counter': counter,
      'numbers': numbers,
    });
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('Foreground service stopped');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('Notification button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    print('Notification pressed');
  }

  // Handle data sent from the app
  @override
  void onReceiveData (dynamic data) {
    print('onDataReceived called with data: $data');
    if (data is Map && data.containsKey('data')) {
      final String receivedData = data['data'] as String;
      print('Service received data: $receivedData');
      FlutterForegroundTask.updateService(
        foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000,),
        notificationTitle: 'Foreground Service',
        notificationText: 'Received: $receivedData',
      );
    } else {
      print('Invalid data format: $data');
    }
  }
}

// Entry point for the foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ServiceTaskHandler());
}

/*
// Initialize the foreground service
Future<void> initializeForegroundService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription: 'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.DEFAULT,
      priority: NotificationPriority.DEFAULT,
      enableVibration: false,
      playSound: false,
      showWhen: false,
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 1000, // Run every 5 seconds
      autoRunOnBoot: false,
      allowWifiLock: true,
    ),
  );
}

// Task handler for the foreground service
class ServiceTaskHandler extends TaskHandler {
  int counter = 0;
  final Random random = Random();
  SendPort? _sendPort;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    print('Foreground service started');
    // Send initial data
    _sendPort?.send({
      'counter': counter,
      'numbers': [],
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    counter++;
    // Generate List<double> (3 random numbers between 0 and 100)
    List<double> numbers = [
      random.nextDouble() * 100,
      random.nextDouble() * 100,
      random.nextDouble() * 100,
    ];
    print('Foreground service running: $counter, numbers: $numbers');

    // Update notification
    await FlutterForegroundTask.updateService(
      foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000, ),
      notificationTitle: 'Foreground Service',
      notificationText: 'Counter: $counter, Numbers: ${numbers.map((n) => n.toStringAsFixed(2)).join(', ')}',
    );

    // Send data to app
    sendPort?.send({
      'counter': counter,
      'numbers': numbers,
    });
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('Foreground service stopped');
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

  // Handle data sent from the app
  void onDataReceived(dynamic data) {
    print ('******* onDataReceived *******');
    if (data is Map && data.containsKey('data')) {
      final String receivedData = data['data'] as String;
      print('Service received data: $receivedData');
      // Update notification with received data
      FlutterForegroundTask.updateService(
        foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000, ),
        notificationTitle: 'Foreground Service',
        notificationText: 'Received: $receivedData',
      );
    }
  }
}

// Entry point for the foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ServiceTaskHandler());
}

 */

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'data_holder.dart';
import 'foreground_service.dart';

// Events
abstract class ServiceEvent {}

class StartService extends ServiceEvent {}

class StopService extends ServiceEvent {}

class SendData extends ServiceEvent {
  final String data;
  SendData(this.data);
}

class UpdateData extends ServiceEvent {
  final int counter;
  final List<double> numbers;
  UpdateData(this.counter, this.numbers);
}

// State
class ServiceState {
  final bool isServiceRunning;
  final int counter;
  final String inputData;
  final List<double> numbers;

  ServiceState({
    required this.isServiceRunning,
    this.counter = 0,
    this.inputData = '',
    this.numbers = const [],
  });
}

// BLoC
class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  StreamSubscription? _dataSubscription;

  ServiceBloc() : super(ServiceState(isServiceRunning: false)) {
    // Check initial service state
    FlutterForegroundTask.isRunningService.then((isRunning) {
      emit(ServiceState(
        isServiceRunning: isRunning,
        counter: state.counter,
        inputData: state.inputData,
        numbers: state.numbers,
      ));
    });

    // Listen for data from the service
    _dataSubscription = FlutterForegroundTask.receivePort?.listen((data) {
      if (data is Map && data.containsKey('counter') && data.containsKey('numbers')) {
        int counter = data['counter'] as int;
        List<double> rawData = List<double>.from(data['numbers'].map((e) => e as double));
        print('receivePort: $counter, numbers: ${rawData.length}');
        DataHolder.instance()?.putData(rawData);
        add(UpdateData(
            counter, rawData
          // data['counter'] as int,
          // List<double>.from(data['numbers'].map((e) => e as double)),
        ));
      }
    });

    on<StartService>((event, emit) async {
      bool isRunning = await FlutterForegroundTask.isRunningService;
      if (!isRunning) {
        await FlutterForegroundTask.startService(
          notificationTitle: 'Foreground Service',
          notificationText: 'Starting...',
          callback: startCallback,
        );
        emit(ServiceState(
          isServiceRunning: true,
          counter: state.counter,
          inputData: state.inputData,
          numbers: state.numbers,
        ));
      }
    });

    on<StopService>((event, emit) async {
      await FlutterForegroundTask.stopService();
      emit(ServiceState(isServiceRunning: false, counter: 0, inputData: '', numbers: []));
    });

    on<SendData>((event, emit) async {
      print('Sending data to service: ${event.data}');
      FlutterForegroundTask.sendData({'data': event.data});
      // Simulate service response
      // await FlutterForegroundTask.updateService(
      //   foregroundTaskOptions: const ForegroundTaskOptions(),
      //   notificationTitle: 'Foreground Service',
      //   notificationText: 'Received: ${event.data}',
      // );
      emit(ServiceState(
        isServiceRunning: state.isServiceRunning,
        counter: state.counter,
        inputData: event.data,
        numbers: state.numbers,
      ));
    });
    /*
    on<SendData>((event, emit) {
      FlutterForegroundTask.sendData({'data': event.data});
      emit(ServiceState(
        isServiceRunning: state.isServiceRunning,
        counter: state.counter,
        inputData: event.data,
        numbers: state.numbers,
      ));
    });
    */

    on<UpdateData>((event, emit) {
      emit(ServiceState(
        isServiceRunning: state.isServiceRunning,
        counter: event.counter,
        inputData: state.inputData,
        numbers: event.numbers,
      ));
    });
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }
}

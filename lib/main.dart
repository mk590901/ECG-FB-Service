import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data_collection/data_holder.dart';
import 'widget/graph_mode.dart';
import 'widget/graph_widget.dart';
import 'service_components/service_bloc.dart';
import 'service_components/foreground_service.dart';

void main() async {
  DataHolder.initInstance();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeForegroundService();
  runApp(ForegroundServiceApp());
}

class ForegroundServiceApp extends StatelessWidget {
  const ForegroundServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceBloc(),
      child: MaterialApp(home: HomeScreen()),
    );
  }
}

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final GraphWidget graphWidget = GraphWidget(
      samplesNumber: 128,
      width: MediaQuery.of(context).size.width,
      height: 120,
      mode: GraphMode.flowing,
    );

    return PopScope(
      canPop: false, // Disable the default behavior of the "back" button
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If pop has already been executed, do nothing
        // Show the dialog box
        final result = await showAppExitDialog(context);

        // Processing user selection
        await reaction(result, context);
        // For 'ignore' we do nothing, the dialog just closes
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Foreground Service App',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic)),
          leading: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white), // Icon widget
            onPressed: () {
              // Add onPressed logic here if need
            },
          ),
          backgroundColor: Colors.lightBlue,
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {
                      if (state.isServiceRunning && state.counter > 0) {
                        if (!graphWidget.isStarted()) {
                          graphWidget.start();
                        }
                      }

                      return Text(
                        state.isServiceRunning
                            ? 'Service is Running'
                            : 'Service is Stopped',
                        style: TextStyle(fontSize: 20),
                      );
                    },
                  ),
                  SizedBox(height: 30),

                  graphWidget,

                  SizedBox(height: 30),

                  BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {
                      return Text(
                        'Counter: ${state.counter}',
                        style: TextStyle(fontSize: 18),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (state.isServiceRunning) {
                                graphWidget.stop();
                                context.read<ServiceBloc>().add(StopService());
                              } else {
                                context.read<ServiceBloc>().add(StartService());
                              }
                            },
                            child: Text(
                              state.isServiceRunning
                                  ? 'Stop Service'
                                  : 'Start Service',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> showAppExitDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Application exit',
              style: TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
            content: Text(
              'Choose one of app exit option:\n\t - Ignore: stay in application\n\t - Close: exit leaving service\n\t - Exit: stop service and exit',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            actions: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, 'ignore'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(40, 36),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        child: Text('Ignore'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, 'close'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(40, 36),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        child: Text('Close'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, 'exit'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(20, 36),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        child: Text('Exit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Future<void> reaction(String? result, BuildContext context) async {
    if (!context.mounted) {
      return;
    }
    if (result == 'close') {
      await SystemNavigator.pop();
    } else if (result == 'exit') {
      if (context.mounted) {
        context.read<ServiceBloc>().add(StopService());
      }
      await SystemNavigator.pop();
    }
  }

  // void runDelayed(Duration delay, Function callback) {
  //   Future.delayed(delay, () {
  //     callback();
  //   });
  // }
}

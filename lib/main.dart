import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'card_widget.dart';
import 'data_holder.dart';
import 'graph_mode.dart';
import 'graph_widget.dart';
import 'service_bloc.dart';
import 'foreground_service.dart';

void main() async {
  DataHolder.initInstance();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeForegroundService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceBloc(),
      child: MaterialApp(home: HomeScreen()),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // CustomCardWidget cardWidget = CustomCardWidget(
    //   graphWidget: GraphWidget(
    //       samplesNumber: 128, //getSeriesLength(),
    //       width: 340,
    //       height: 100,
    //       mode: GraphMode.flowing),
    //   onDeleteWidgetAction: () {},
    // );

    final GraphWidget graphWidget = GraphWidget(
          samplesNumber: 128, //getSeriesLength(),
          width: 340,
          height: 120,
          mode: GraphMode.flowing);

    return PopScope(
      canPop: false, // Disable the default behavior of the "back" button
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If pop has already been executed, do nothing
        // Show the dialog box
        final result = await showDialog<String>(
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

        // Processing user selection
        await reaction(result, context);
        // For 'ignore' we do nothing, the dialog just closes
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Foreground Service App')),
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

                  //cardWidget,
                  graphWidget,

                  // CustomCardWidget(
                  //     graphWidget: GraphWidget(
                  //         samplesNumber: 128, //getSeriesLength(),
                  //         width: 340,
                  //         height: 100,
                  //         mode: GraphMode.flowing),
                  //         onDeleteWidgetAction: () {},
                  // ),

                  SizedBox(height: 30),

                  BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {

    //                if (state.isServiceRunning && state.counter == 1) {
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
                  SizedBox(height: 10),
                  BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {
                      return Text(
                        'Counter: ${state.counter}',
                        style: TextStyle(fontSize: 18),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  // BlocBuilder<ServiceBloc, ServiceState>(
                  //   builder: (context, state) {
                  //     return Text(
                  //       'Numbers: ${state.numbers.map((n) => n.toStringAsFixed(2)).join(', ')}',
                  //       style: TextStyle(fontSize: 16),
                  //     );
                  //   },
                  // ),
                  SizedBox(height: 10),
                  // TextField(
                  //   controller: _controller,
                  //   decoration: InputDecoration(
                  //     labelText: 'Enter data to send',
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          // Text(
                          //   'Last sent data: ${state.inputData}',
                          //   style: TextStyle(fontSize: 16),
                          // ),
                          // SizedBox(height: 10),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     final String data = _controller.text.trim();
                          //     if (data.isNotEmpty) {
                          //       print('Button pressed, sending: $data');
                          //       context.read<ServiceBloc>().add(SendData(data));
                          //       _controller.clear(); // Uncomment to clear field
                          //     }
                          //   },
                          //   child: Text('Send Data to Service'),
                          // ),
                          // SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (state.isServiceRunning) {
                                graphWidget.stop();
                                context.read<ServiceBloc>().add(StopService());
                              } else {
                                context.read<ServiceBloc>().add(StartService());
                                // runDelayed(const Duration(seconds: 2), () {
                                //   graphWidget.start();
                                // });
                                //cardWidget.start();
                              }
                              //graphWidget.onStartStop();
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


  void runDelayed(Duration delay, Function callback) {
    Future.delayed(delay, () {
      callback();
    });
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../data_collection/obtained.dart';
import '../states/drawing_state.dart';
import '../data_collection/ecg_wrapper.dart';
import 'drawing_bloc.dart';
import 'graph_mode.dart';
import 'path_painter.dart';

class GraphWidget extends StatelessWidget {
  static const int FREQ = 24; // frames-per-seconds
  final int PERIOD = 1000; // 1s = 1000ms

  final int samplesNumber;
  final double width;
  final double height;
  final GraphMode mode;
  final String uuid = const Uuid().v4().toString();

  late ECGWrapper storeWrapper;

  final Obtained obtain = Obtained.part(const Duration(milliseconds: FREQ));

  GraphWidget(
      {super.key,
      required this.samplesNumber,
      required this.width,
      required this.height,
      required this.mode,
      }) {
    int pointsToDraw =
        (samplesNumber.toDouble() / (PERIOD.toDouble() / FREQ.toDouble())).toInt() + 1;
    storeWrapper = ECGWrapper(samplesNumber, 5, pointsToDraw, mode);
  }

  bool isStarted() {
    return obtain.isActive();
  }

  void start() {
    storeWrapper.start();
    obtain.start(uuid);
  }

  void stop() {
    obtain.stop(uuid);
    storeWrapper.stop();
  }

  void onChangeMode() {
    storeWrapper.setMode(isFlowing() ? GraphMode.overlay : GraphMode.flowing);
  }

  bool isFlowing() {
    return storeWrapper.mode() == GraphMode.flowing;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DrawingBloc>(
      create: (_) => DrawingBloc(DrawingState(DrawingStates.drawing)),
      child: GestureDetector(
        onTap: () {
          onChangeMode();
        },
        child:
            BlocBuilder<DrawingBloc, DrawingState>(builder: (context, state) {
          obtain.set(storeWrapper.drawingFrequency(), context);
          storeWrapper.updateBuffer(state.counter());
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: width,
                height: height,
                child: CustomPaint(
                  painter: PathPainter.graph(state.counter(), storeWrapper),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void dispose() {
    obtain.stop(uuid);
    storeWrapper.stop();
  }
}

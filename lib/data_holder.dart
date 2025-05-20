import 'circular_buffer.dart';
import 'ecg_simulator/ecg_simulator.dart';

class DataHolder {
  static DataHolder? _instance;

  late List<double> rowData = [];

  static void initInstance() {
    _instance ??= DataHolder();
    print ('initInstance -- Ok');
  }

  static DataHolder? instance() {
    if (_instance == null) {
      throw Exception("--- DataHolder was not initialized ---");
    }
    return _instance;
  }

  List<double> getData() {
    return rowData;
  }

  void putData(List<double> data) {
    rowData = data;
  }


}

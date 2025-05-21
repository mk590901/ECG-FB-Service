import 'dart:math';
import 'data_collection/circular_buffer.dart';
import 'data_collection/ecg_wrapper.dart';

List<int> extractRangeData(final List<int> rowData, final int start, final int number) {
  List<int> result = <int>[];

  if (rowData.isEmpty) {
    return result;
  }

  if (start < 0) {
    return result;
  }

  if (number <= 0) {
    return result;
  }

  int rowLength = rowData.length;

  if (start >= rowLength) {
    return result;
  }

  if (rowData.length <= start + number) {
    result = rowData.sublist(start, rowLength);
    return result;
  }
  // result = rowData.sublist(start, start + number);
  // print ('[$start,${start + number}]');
  int fin = start + number;
  if ((fin + number) > rowLength) {
    fin += rowLength - fin;
  }

  result = rowData.sublist(start, fin);
  //print ('[$start,$fin]');

  return result;
}
int getSeriesLength() {
  List<int> series = [128, 256, 512, 1024];
  final random = Random();
  int randomIdx = random.nextInt(series.length); // Generates 0, 1, 2, 3, 4, 5, or 6, ...
  return series[randomIdx];
}

int getRandomValue(final int min, final int max) {
  return Random().nextInt(max - min + 1) + min;
}

double getMin(List<int> rowData, int rowSize) {
  int min = rowData[0];
  for (int i = 1; i < rowSize; i++) {
    if (rowData[i] < min) {
      min = rowData[i];
    }
  }
  return min.toDouble();
}

double getMax(List<int> rowData, int rowSize) {
  int max = rowData[0];
  for (int i = 1; i < rowSize; i++) {
    if (rowData[i] > max) {
      max = rowData[i];
    }
  }
  return max.toDouble();
}

double getMinB(final CircularBuffer<int> buffer) {
  List<int?> rowData = buffer.buffer();
  int? min = rowData[0];
  int minV = (min == null) ? 0 : min;
  for (int i = 1; i < buffer.capacity(); i++) {
    int? value = rowData[i];
    int valueV = (value == null) ? 0 : value;
    if (valueV < minV) {
      minV = valueV;
    }
  }
  return minV.toDouble();
}

double getMaxB(final CircularBuffer<int> buffer) {
  List<int?> rowData = buffer.buffer();
  int? max = rowData[0];
  int maxV = (max == null) ? 0 : max;
  for (int i = 1; i < buffer.capacity(); i++) {
    int? value = rowData[i];
    int valueV = (value == null) ? 0 : value;
    if (valueV > maxV) {
      maxV = valueV;
    }
  }
  return maxV.toDouble();
}

int getMinForFullBuffer(final CircularBuffer<int> buffer) {
  int result = 0;
  List<int?> rowData = buffer.buffer();
  if (rowData[0] == null) {
    result = rowData[1]!;
  }
  else {
    result = rowData[0]!;
  }
  return result;
}

List<int> dataSeriesOverlay(CircularBuffer<int> buffer) {
  int seriesSize =
    buffer.size() < buffer.capacity() - 1 ? buffer.size() : buffer.capacity();
  List<int> result = List<int>.filled(seriesSize, 0);
  for (int i = 0; i < seriesSize; i++) {
    int? value = buffer.getDirect(i); //  getPure()
    if (value != null) {
      result[i] = value;
    } else {
      result[i] = result[i - 1];
    }
  }
  return result;
}

List<int> dataSeriesNormal(ECGWrapper storeWrapper) {
  storeWrapper.storeCircularBufferParams();
  List<int> result = storeWrapper.buffer().getData();
  storeWrapper.restoreCircularBufferParams();
  return result;
}

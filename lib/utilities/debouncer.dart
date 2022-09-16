import 'dart:async';
import 'dart:math';
import 'dart:ui';

class Debouncer {

  final int milliSeconds;
  Timer? _timer;

  Debouncer({required this.milliSeconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliSeconds), action);
  }
}
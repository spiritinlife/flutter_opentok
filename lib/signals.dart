import 'package:flutter/material.dart';
import 'signal.dart';

class Signals extends ChangeNotifier {
  List<Signal> signals = List();

  addSignal(Signal signal) {
    signals.insert(0, signal);
    notifyListeners();
  }
}
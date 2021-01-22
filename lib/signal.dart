class Signal {
  final bool isRemote;
  final String data;
  final String type;

  Signal._(this.isRemote, this.data, this.type);

  factory Signal.fromMap(Map data) =>
      Signal._(data['isRemote'], data['data'], data['type']);
}

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  final String id;
  final String expression;
  final String result;
  final int timestamp;

  HistoryEntry copyWith({
    String? id,
    String? expression,
    String? result,
    int? timestamp,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'expression': expression,
        'result': result,
        'timestamp': timestamp,
      };

  factory HistoryEntry.fromJson(Map<String, Object?> json) {
    return HistoryEntry(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      expression: json['expression'] as String? ?? '',
      result: json['result'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? DateTime.now().microsecondsSinceEpoch,
    );
  }

  DateTime get date => DateTime.fromMicrosecondsSinceEpoch(timestamp);
}

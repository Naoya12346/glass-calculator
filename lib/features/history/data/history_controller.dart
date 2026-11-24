import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/history_entry.dart';

class HistoryController extends ChangeNotifier {
  static const int _maxEntries = 200;

  List<HistoryEntry> _entries = <HistoryEntry>[];
  String _query = '';
  SharedPreferences? _prefs;

  List<HistoryEntry> get entries => List.unmodifiable(_entries);
  String get query => _query;

  List<HistoryEntry> get filteredEntries {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return entries;
    return _entries
        .where(
          (entry) =>
              entry.expression.toLowerCase().contains(needle) ||
              entry.result.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getStringList(_key) ?? <String>[];
    _entries = raw
        .map((item) {
          try {
            return HistoryEntry.fromJson(
              jsonDecode(item) as Map<String, Object?>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<HistoryEntry>()
        .toList();
    notifyListeners();
  }

  Future<void> add({
    required String expression,
    required String result,
  }) async {
    final entry = HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      expression: expression.trim(),
      result: result.trim(),
      timestamp: DateTime.now().microsecondsSinceEpoch,
    );
    _entries = <HistoryEntry>[entry, ..._entries];
    if (_entries.length > _maxEntries) {
      _entries = _entries.sublist(0, _maxEntries);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _entries = <HistoryEntry>[];
    notifyListeners();
    await _persist();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = _entries.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  static const String _key = 'history.entries.v1';
}

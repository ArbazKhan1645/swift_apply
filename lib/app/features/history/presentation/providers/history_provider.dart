import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/features/history/data/models/job_history_model.dart';
import 'package:swift_apply/app/features/history/data/repositories/history_repository.dart';

@injectable
class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._repository);

  final HistoryRepository _repository;

  bool _loading = false;
  List<JobHistory> _items = const [];
  String _query = '';
  String _filter = 'all';

  bool get loading => _loading;
  List<JobHistory> get items => _items;
  String get query => _query;
  String get filter => _filter;
  List<JobHistory> get visibleItems {
    return _items.where((item) {
      final matchesFilter = _filter == 'all' || item.type == _filter;
      final haystack =
          '${item.recipient} ${item.cvName ?? ''} ${item.note ?? ''}'
              .toLowerCase();
      return matchesFilter && haystack.contains(_query.toLowerCase());
    }).toList();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _repository.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.deleteEntry(id);
    await load();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    await load();
  }
}

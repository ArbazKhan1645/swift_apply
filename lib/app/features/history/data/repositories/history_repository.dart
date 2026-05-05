import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/core/database/db_service.dart';
import 'package:swift_apply/app/features/history/data/models/job_history_model.dart';

@lazySingleton
class HistoryRepository {
  HistoryRepository(this._db);

  final DatabaseService _db;

  Future<List<JobHistory>> getAll({int limit = 100}) async {
    final db = await _db.database;
    final results = await db.query(
      'job_history',
      orderBy: 'sent_at DESC',
      limit: limit,
    );
    return results.map(JobHistory.fromMap).toList();
  }

  Future<int> addEntry(JobHistory entry) async {
    final db = await _db.database;
    return await db.insert('job_history', entry.toMap());
  }

  Future<void> deleteEntry(int id) async {
    final db = await _db.database;
    await db.delete('job_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('job_history');
  }

  Future<Map<String, int>> getStats() async {
    final db = await _db.database;
    final all = await db.query('job_history');
    final emails = all.where((r) => r['type'] == 'email').length;
    final whatsapps = all.where((r) => r['type'] == 'whatsapp').length;
    return {'total': all.length, 'emails': emails, 'whatsapps': whatsapps};
  }
}

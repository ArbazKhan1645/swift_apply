import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/core/database/db_service.dart';
import 'package:swift_apply/app/features/job_leads/data/models/job_lead_model.dart';

@lazySingleton
class JobLeadRepository {
  JobLeadRepository(this._db);

  final DatabaseService _db;

  Future<List<JobLead>> getAll() async {
    final db = await _db.database;
    final results = await db.query(
      'job_leads',
      orderBy:
          "CASE priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END, updated_at DESC",
    );
    return results.map(JobLead.fromMap).toList();
  }

  Future<int> add(JobLead lead) async {
    final db = await _db.database;
    return db.insert('job_leads', lead.toMap());
  }

  Future<JobLead?> getById(int id) async {
    final db = await _db.database;
    final results = await db.query(
      'job_leads',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return JobLead.fromMap(results.first);
  }

  Future<JobLead?> findDuplicate({
    required String rawText,
    required String sourceUrl,
  }) async {
    final db = await _db.database;
    final results = await db.query(
      'job_leads',
      where: sourceUrl.isNotEmpty ? 'source_url = ?' : 'raw_text = ?',
      whereArgs: [sourceUrl.isNotEmpty ? sourceUrl : rawText],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return JobLead.fromMap(results.first);
  }

  Future<void> update(JobLead lead) async {
    final id = lead.id;
    if (id == null) return;
    final db = await _db.database;
    await db.update(
      'job_leads',
      lead.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('job_leads', where: 'id = ?', whereArgs: [id]);
  }
}

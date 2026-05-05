import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/core/database/db_service.dart';
import 'package:swift_apply/app/features/cv/data/models/cv_file_model.dart';

@lazySingleton
class CvRepository {
  CvRepository(this._db);

  final DatabaseService _db;

  Future<List<CvFile>> getAllCvs() async {
    final db = await _db.database;
    final results = await db.query('cv_files', orderBy: 'added_at DESC');
    return results.map(CvFile.fromMap).toList();
  }

  Future<CvFile?> getDefaultCv() async {
    final db = await _db.database;
    final results = await db.query(
      'cv_files',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CvFile.fromMap(results.first);
  }

  Future<int> addCv(CvFile cv) async {
    final db = await _db.database;
    return await db.insert('cv_files', cv.toMap());
  }

  Future<void> deleteCv(int id) async {
    final db = await _db.database;
    await db.delete('cv_files', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setDefault(int id) async {
    final db = await _db.database;
    await db.update('cv_files', {'is_default': 0});
    await db.update(
      'cv_files',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> renameCv(int id, String newName) async {
    final db = await _db.database;
    await db.update(
      'cv_files',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

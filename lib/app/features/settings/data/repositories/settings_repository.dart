import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/core/database/db_service.dart';
import 'package:swift_apply/app/features/settings/data/models/settings_model.dart';

@lazySingleton
class SettingsRepository {
  SettingsRepository(this._db);

  final DatabaseService _db;

  Future<AppSettings> getSettings() async {
    final db = await _db.database;
    final results = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    if (results.isEmpty) {
      return const AppSettings(
        senderName: '',
        senderEmail: '',
        emailPassword: '',
        smtpHost: 'smtp.gmail.com',
        smtpPort: 587,
        emailTemplate:
            'Dear Hiring Manager,\n\nI am writing to express my interest in the {position} role at {company}.\n\nI have {experience} years of experience with {skills}.\n\nBest regards,\n{name}',
        emailSubject: '{position} Application - {name}',
        whatsappTemplate:
            'Assalam o Alaikum,\n\nI am {name}, a {position} with {experience} years of experience in {skills}.\n\nAny {position} openings at {company}?',
      );
    }
    return AppSettings.fromMap(results.first);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await _db.database;
    await db.update(
      'settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}

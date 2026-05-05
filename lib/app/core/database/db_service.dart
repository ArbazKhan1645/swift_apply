import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jobblast.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumn(
        db,
        'settings',
        "target_position TEXT NOT NULL DEFAULT 'Flutter Developer'",
      );
      await _addColumn(
        db,
        'settings',
        "experience_years TEXT NOT NULL DEFAULT '3'",
      );
      await _addColumn(
        db,
        'settings',
        "skills TEXT NOT NULL DEFAULT 'Flutter, Dart, Firebase, REST APIs'",
      );
      await _addColumn(db, 'settings', "location TEXT NOT NULL DEFAULT ''");
      await _addColumn(
        db,
        'settings',
        "default_country_code TEXT NOT NULL DEFAULT ''",
      );
      await _addColumn(
        db,
        'settings',
        'auto_attach_default_cv INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (oldVersion < 3) {
      await _createJobLeadsTable(db);
    }
    if (oldVersion < 4) {
      await _addColumn(db, 'settings', "wa_api_key TEXT NOT NULL DEFAULT ''");
      await _addColumn(db, 'settings', "wa_phone_id TEXT NOT NULL DEFAULT ''");
      await _addColumn(db, 'settings', "wa_business_id TEXT NOT NULL DEFAULT ''");
    }
  }

  Future<void> _addColumn(Database db, String table, String definition) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $definition');
    } on DatabaseException catch (e) {
      if (!e.isDuplicateColumnError()) rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        sender_name TEXT NOT NULL DEFAULT '',
        sender_email TEXT NOT NULL DEFAULT '',
        email_password TEXT NOT NULL DEFAULT '',
        smtp_host TEXT NOT NULL DEFAULT 'smtp.gmail.com',
        smtp_port INTEGER NOT NULL DEFAULT 587,
        email_template TEXT NOT NULL DEFAULT '',
        email_subject TEXT NOT NULL DEFAULT '',
        whatsapp_template TEXT NOT NULL DEFAULT '',
        target_position TEXT NOT NULL DEFAULT 'Flutter Developer',
        experience_years TEXT NOT NULL DEFAULT '3',
        skills TEXT NOT NULL DEFAULT 'Flutter, Dart, Firebase, REST APIs',
        location TEXT NOT NULL DEFAULT '',
        default_country_code TEXT NOT NULL DEFAULT '',
        auto_attach_default_cv INTEGER NOT NULL DEFAULT 1,
        wa_api_key TEXT NOT NULL DEFAULT '',
        wa_phone_id TEXT NOT NULL DEFAULT '',
        wa_business_id TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE cv_files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        added_at TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE job_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipient TEXT NOT NULL,
        type TEXT NOT NULL,
        cv_name TEXT,
        sent_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'sent',
        note TEXT
      )
    ''');

    await _createJobLeadsTable(db);

    await db.insert('settings', {
      'id': 1,
      'sender_name': '',
      'sender_email': '',
      'email_password': '',
      'smtp_host': 'smtp.gmail.com',
      'smtp_port': 587,
      'email_template':
          'Dear Hiring Manager,\n\nI am writing to express my interest in the {position} role at {company}.\n\nI have {experience} years of experience with {skills}. I am based in {location} and can contribute to your team with clean, reliable mobile app development.\n\nI have attached my CV for your review.\n\nBest regards,\n{name}',
      'email_subject': '{position} Application - {name}',
      'whatsapp_template':
          'Assalam o Alaikum,\n\nI am {name}, a {position} with {experience} years of experience in {skills}.\n\nI wanted to ask if there are any {position} openings at {company}.\n\nThank you.',
      'target_position': 'Flutter Developer',
      'experience_years': '3',
      'skills': 'Flutter, Dart, Firebase, REST APIs',
      'location': '',
      'default_country_code': '',
      'auto_attach_default_cv': 1,
      'wa_api_key': '',
      'wa_phone_id': '',
      'wa_business_id': '',
    });
  }

  Future<void> _createJobLeadsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS job_leads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company TEXT NOT NULL DEFAULT '',
        position TEXT NOT NULL DEFAULT '',
        location TEXT NOT NULL DEFAULT '',
        salary TEXT NOT NULL DEFAULT '',
        source_url TEXT NOT NULL DEFAULT '',
        contact_email TEXT NOT NULL DEFAULT '',
        contact_phone TEXT NOT NULL DEFAULT '',
        raw_text TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'saved',
        priority TEXT NOT NULL DEFAULT 'medium',
        follow_up_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
}

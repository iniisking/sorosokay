import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

const _legacyMigrationKey = '_legacy_shared_prefs_migrated';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    await _migrateLegacySharedPreferencesOnce();
    return _database!;
  }

  /// One-time copy of notes + theme from SharedPreferences (older app versions).
  /// Uses [db] only — must not call [database] / [getPreference] (would recurse).
  Future<void> _migrateLegacySharedPreferencesOnce() async {
    final db = _database;
    if (db == null) return;

    Future<String?> readPref(String key) async {
      final rows = await db.query(
        'preferences',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['value'] as String;
    }

    Future<void> writePref(String key, String value) async {
      await db.insert(
        'preferences',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    if (await readPref(_legacyMigrationKey) == '1') return;

    final prefs = await SharedPreferences.getInstance();

    if (await readPref('theme_mode') == null) {
      final wasDark = prefs.getBool('theme_mode');
      if (wasDark == true) {
        await writePref('theme_mode', 'dark');
      } else if (wasDark == false) {
        await writePref('theme_mode', 'light');
      }
    }

    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      final decoded = jsonDecode(notesJson);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map) {
            final note = Note.fromMap(Map<String, Object?>.from(item));
            await db.insert(
              'notes',
              note.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    }

    await writePref(_legacyMigrationKey, '1');
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sorosokay.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id TEXT PRIMARY KEY,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE preferences (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'timestamp DESC');
    return rows.map((row) => Note.fromMap(row)).toList();
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(String id, String content) async {
    final db = await database;
    await db.update(
      'notes',
      {'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getPreference(String key) async {
    final db = await database;
    final rows = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

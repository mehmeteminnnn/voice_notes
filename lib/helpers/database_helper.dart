import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/audio_file.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'audio_notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE audio_files(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        filePath TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        audioId INTEGER NOT NULL,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (audioId) REFERENCES audio_files (id)
      )
    ''');
  }

  // Audio File işlemleri
  Future<int> insertAudioFile(AudioFile audioFile) async {
    final db = await database;
    return await db.insert('audio_files', audioFile.toMap());
  }

  Future<List<AudioFile>> getAudioFiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('audio_files');
    return List.generate(maps.length, (i) => AudioFile.fromMap(maps[i]));
  }

  Future<void> deleteAudioFile(int id) async {
    final db = await database;
    await db.delete('notes', where: 'audioId = ?', whereArgs: [id]);
    await db.delete('audio_files', where: 'id = ?', whereArgs: [id]);
  }

  // Note işlemleri
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesForAudio(int audioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'audioId = ?',
      whereArgs: [audioId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

class DBService {
  static Database? _db;

  // Getter aman untuk _db
  static Database get db {
    if (_db == null) {
      throw Exception(
        "Database belum diinisialisasi. Panggil DBService.initDb() terlebih dahulu.",
      );
    }
    return _db!;
  }

  // Inisialisasi Database
  static Future<void> initDb() async {
    if (_db != null) return;

    // Hanya gunakan sqflite_ffi untuk desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = join(await getDatabasesPath(), 'quiz_app.db');

    _db = await openDatabase(
      dbPath,
      version: 2, // versi ditingkatkan agar trigger onCreate jika perlu
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            score INTEGER,
            timestamp TEXT
          )
        ''');

        print('📦 Database dan tabel berhasil dibuat.');
      },
    );
  }

  /// 🔐 Register user baru
  static Future<void> registerUser(String username, String password) async {
    await db.insert('users', {'username': username, 'password': password});
  }

  /// 🔐 Cek apakah user ada
  static Future<bool> userExists(String username) async {
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  /// 🔐 Login user
  static Future<bool> loginUser(String username, String password) async {
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  /// 💾 Simpan skor kuis
  static Future<void> saveScore({
    required String username,
    required int score,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    await db.insert('scores', {
      'username': username,
      'score': score,
      'timestamp': timestamp,
    });
  }

  /// 📈 Ambil skor tertinggi user
  static Future<int> getBestScore(String username) async {
    final result = await db.rawQuery(
      'SELECT MAX(score) as best FROM scores WHERE username = ?',
      [username],
    );
    final best = result.first['best'];
    return best == null ? 0 : (best as int);
  }

  /// 📊 Ambil semua skor (riwayat)
  static Future<List<Map<String, dynamic>>> getAllScores() async {
    return await db.query('scores', orderBy: 'timestamp DESC');
  }

  /// 📋 Ambil skor user tertentu
  static Future<List<Map<String, dynamic>>> getScoresByUser(
    String username,
  ) async {
    return await db.query(
      'scores',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'timestamp DESC',
    );
  }
}

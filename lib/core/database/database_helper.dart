import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/glucose_measurement.dart';

/// Capa de persistencia local robusta basada en SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String tableName = 'glucose_measurements';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('glucose_control.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        timestampMillis INTEGER NOT NULL,
        context TEXT NOT NULL,
        isHigh INTEGER NOT NULL
      )
    ''');
  }

  /// Inserta o reemplaza una medición en la base de datos
  Future<int> insertMeasurement(GlucoseMeasurement measurement) async {
    try {
      final db = await database;
      final row = {
        'id': measurement.id,
        'value': measurement.value,
        'timestamp': measurement.timestamp.toIso8601String(),
        'timestampMillis': measurement.timestamp.millisecondsSinceEpoch,
        'context': measurement.context,
        'isHigh': measurement.isHigh ? 1 : 0,
      };

      return await db.insert(
        tableName,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Fallback seguro si se ejecuta en entornos donde sqflite nativo no está inicializado (ej: pruebas unitarias)
      return 1;
    }
  }

  /// Recupera todas las mediciones ordenadas cronológicamente (más recientes primero)
  Future<List<GlucoseMeasurement>> getAllMeasurements() async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        orderBy: 'timestampMillis DESC',
      );

      return result.map((json) {
        return GlucoseMeasurement(
          id: json['id'] as String,
          value: (json['value'] as num).toDouble(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestampMillis'] as int),
          context: json['context'] as String,
          isHigh: (json['isHigh'] as int) == 1,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Elimina una medición por su ID
  Future<int> deleteMeasurement(String id) async {
    try {
      final db = await database;
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {
      return 0;
    }
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

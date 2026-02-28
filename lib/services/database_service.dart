import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auto_alert.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            app_name TEXT,
            amount TEXT,
            timestamp TEXT
          )
        ''');
      },
      onOpen: (db) async {
        await _deleteOldTransactions(db);
      },
    );
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    await _deleteOldTransactions(db);
    return await db.insert('transactions', transaction.toMap());
  }

  Future<void> _deleteOldTransactions(Database db) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await db.delete(
      'transactions',
      where: 'timestamp < ?',
      whereArgs: [thirtyDaysAgo.toIso8601String()],
    );
  }

  Future<List<TransactionModel>> getTransactions({
    int limit = 100,
    String? filterApp,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (filterApp != null && filterApp != 'All') {
      whereClause += 'app_name LIKE ?';
      whereArgs.add('%$filterApp%');
    }

    if (startDate != null && endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp >= ? AND timestamp <= ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'expense.dart';

abstract class ExpenseRepo {
  Future<List<Expense>> getAll();
  Future<void> add(Expense e);
  Future<void> update(Expense e);
  Future<void> delete(int id);
}

// ===================== SQLite =====================
class SqliteExpenseRepo implements ExpenseRepo {
  Database? _db;

  // Buat database + tabel (dijalankan sekali saat pertama dibuka)
  Future<Database> get _database async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'expense.db'),
      version: 1,
      onCreate: (db, v) => db.execute(
        'CREATE TABLE expenses('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title TEXT NOT NULL, '
        'amount INTEGER NOT NULL)',
      ),
    );
    return _db!;
  }

  // READ
  @override
  Future<List<Expense>> getAll() async {
    final rows = await (await _database).query('expenses', orderBy: 'id DESC');
    return rows
        .map((r) => Expense(
              id: r['id'] as int,
              title: r['title'] as String,
              amount: r['amount'] as int,
            ))
        .toList();
  }

  // CREATE
  @override
  Future<void> add(Expense e) async {
    await (await _database)
        .insert('expenses', {'title': e.title, 'amount': e.amount});
  }

  // UPDATE
  @override
  Future<void> update(Expense e) async {
    await (await _database).update(
      'expenses',
      {'title': e.title, 'amount': e.amount},
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  // DELETE
  @override
  Future<void> delete(int id) async {
    await (await _database).delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}

// ===================== Hive =====================
class HiveExpenseRepo implements ExpenseRepo {
  final Box _box = Hive.box('expense_box');

  @override
  Future<List<Expense>> getAll() async {
    final list = _box.keys.map((k) {
      final m = _box.get(k) as Map;
      return Expense(
        id: k as int,
        title: m['title'] as String,
        amount: m['amount'] as int,
      );
    }).toList();
    list.sort((a, b) => b.id!.compareTo(a.id!));
    return list;
  }

  @override
  Future<void> add(Expense e) async {
    await _box.add({'title': e.title, 'amount': e.amount});
  }

  @override
  Future<void> update(Expense e) async {
    await _box.put(e.id, {'title': e.title, 'amount': e.amount});
  }

  @override
  Future<void> delete(int id) async {
    await _box.delete(id);
  }
}
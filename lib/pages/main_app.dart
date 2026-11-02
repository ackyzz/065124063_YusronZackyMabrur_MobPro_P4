import 'package:flutter/material.dart';
import '../data/expense_repo.dart';
import 'expense_page.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Widget _menu(BuildContext context, String storage, Color color,
      ExpenseRepo Function() repo) {
    return Column(
      children: [
        const Text('Catatan Pengeluaran', style: TextStyle(fontSize: 20)),
        Text(
          'Storage: $storage',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExpensePage(
                title: 'Pengeluaran ($storage)',
                color: color,
                repo: repo(),
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text('Buka Aplikasi'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text(
          'Main App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menu(context, 'sqflite', Colors.green[700]!,
                () => SqliteExpenseRepo()),
            const SizedBox(height: 50),
            _menu(context, 'hive', Colors.deepPurple,
                () => HiveExpenseRepo()),
          ],
        ),
      ),
    );
  }
}
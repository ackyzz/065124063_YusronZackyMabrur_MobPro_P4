import 'package:flutter/material.dart';
import '../data/expense.dart';
import '../data/expense_repo.dart';

class ExpensePage extends StatefulWidget {
  final String title;
  final Color color;
  final ExpenseRepo repo;

  const ExpensePage({
    super.key,
    required this.title,
    required this.color,
    required this.repo,
  });

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  List<Expense> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.repo.getAll();
    setState(() => _items = data);
  }

  int get _total => _items.fold(0, (sum, e) => sum + e.amount);

  String _rp(int n) =>
      'Rp ${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _add() async {
    final title = _titleCtrl.text.trim();
    final amount = int.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty || amount == null) {
      _msg('Isi keterangan dan nominal (angka)');
      return;
    }
    await widget.repo.add(Expense(title: title, amount: amount));
    _titleCtrl.clear();
    _amountCtrl.clear();
    _load();
  }

  Future<void> _delete(int id) async {
    await widget.repo.delete(id);
    _load();
  }

  Future<void> _showUpdate(Expense e) async {
    final t = TextEditingController(text: e.title);
    final a = TextEditingController(text: e.amount.toString());
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Pengeluaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: t,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: a,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final amount = int.tryParse(a.text.trim());
              if (t.text.trim().isEmpty || amount == null) return;
              await widget.repo.update(
                Expense(id: e.id, title: t.text.trim(), amount: amount),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Catat Pengeluaran',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const Divider(height: 28, thickness: 2),
            Text(
              'Total: ${_rp(_total)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final e = _items[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.payments),
                      title: Text(e.title),
                      subtitle: Text(_rp(e.amount)),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'update') {
                            _showUpdate(e);
                          } else {
                            _delete(e.id!);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'update', child: Text('Update')),
                          PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
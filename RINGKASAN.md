# 📦 Ringkasan & Dokumentasi: Local Storage di Flutter
**Tugas Praktikum Mobile Programming**
**Nama Aplikasi:** tugas_storage

---

## 1. SQLite dengan Package `sqflite`

### Apa itu SQFlite?
`sqflite` adalah package Flutter yang memungkinkan penggunaan database **SQLite** — database relasional berbasis file yang ringan dan tidak memerlukan server. Data disimpan dalam satu file `.db` di penyimpanan lokal perangkat.

### Cara Kerja
1. Database dibuka/dibuat menggunakan `openDatabase()` dengan path file
2. Skema tabel didefinisikan menggunakan SQL standar (`CREATE TABLE`)
3. Operasi CRUD dilakukan menggunakan method `insert`, `query`, `update`, `delete`
4. Di desktop (Windows/Linux/macOS), dibutuhkan `sqflite_common_ffi`
5. Di web (browser), dibutuhkan `sqflite_common_ffi_web` + WebAssembly

### Skema Tabel yang Dibuat
```sql
CREATE TABLE expenses (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  title  TEXT    NOT NULL,
  amount INTEGER NOT NULL
)
```

### Implementasi CRUD

| Operasi | Method | Kode |
|---------|--------|------|
| **Create** | `insert()` | `db.insert('expenses', {'title': ..., 'amount': ...})` |
| **Read** | `query()` | `db.query('expenses', orderBy: 'id DESC')` |
| **Update** | `update()` | `db.update('expenses', {...}, where: 'id = ?', whereArgs: [id])` |
| **Delete** | `delete()` | `db.delete('expenses', where: 'id = ?', whereArgs: [id])` |

### Kelebihan SQFlite
- ✅ Mendukung query SQL yang kompleks (JOIN, WHERE, ORDER BY, dll.)
- ✅ Data terstruktur dengan skema yang ketat (type-safe)
- ✅ Cocok untuk data relasional dan jumlah besar
- ✅ Familiar bagi yang sudah mengenal SQL
- ✅ Mendukung transaksi (ACID compliant)

### Kekurangan SQFlite
- ❌ Perlu definisi skema manual (lebih verbose)
- ❌ Tidak mendukung web secara native (butuh FFI Web tambahan)
- ❌ Mapping dari `Map<String, dynamic>` ke model harus dilakukan manual

---

## 2. Hive (Local Storage Alternatif)

### Apa itu Hive?
`hive` adalah database **NoSQL key-value** yang ringan dan sangat cepat, ditulis murni dalam Dart. Data disimpan dalam "Box" (seperti tabel) sebagai pasangan key-value. Tidak memerlukan SQLite atau library native.

### Cara Kerja
1. Hive diinisialisasi dengan `Hive.initFlutter()`
2. "Box" dibuka dengan `Hive.openBox('nama_box')`
3. Data disimpan sebagai `Map` dengan key integer otomatis (`box.add(...)`)
4. Operasi CRUD dilakukan langsung pada Box tanpa SQL

### Implementasi CRUD

| Operasi | Method | Kode |
|---------|--------|------|
| **Create** | `box.add()` | `_box.add({'title': ..., 'amount': ...})` |
| **Read** | `box.get()` | `_box.keys.map((k) => _box.get(k))` |
| **Update** | `box.put()` | `_box.put(id, {'title': ..., 'amount': ...})` |
| **Delete** | `box.delete()` | `_box.delete(id)` |

### Kelebihan Hive
- ✅ Sangat cepat — tidak ada overhead SQL parsing
- ✅ Murni Dart, tidak ada dependency native
- ✅ Mendukung semua platform (Android, iOS, Web, Desktop) tanpa konfigurasi tambahan
- ✅ API sederhana dan mudah dipahami
- ✅ Mendukung enkripsi data (HiveAesCipher)

### Kekurangan Hive
- ❌ Tidak mendukung query kompleks (tidak bisa JOIN atau filter SQL)
- ❌ Skema tidak strict — rentan error jika struktur data berubah
- ❌ Kurang cocok untuk data relasional yang kompleks
- ❌ Untuk object Dart custom, perlu `TypeAdapter` (kode tambahan)

---

## 3. Perbandingan SQFlite vs Hive

| Aspek | SQFlite | Hive |
|-------|---------|------|
| **Tipe** | Relasional (SQL) | NoSQL (Key-Value) |
| **Bahasa Query** | SQL | Dart API |
| **Kecepatan** | Lebih lambat (parsing SQL) | Sangat cepat |
| **Web Support** | ❌ Butuh FFI Web tambahan | ✅ Native |
| **Query Kompleks** | ✅ Bisa JOIN, WHERE, ORDER | ❌ Terbatas |
| **Kemudahan Setup** | Perlu skema SQL | Langsung pakai |
| **Ukuran Package** | Lebih besar | Lebih ringan |
| **Cocok untuk** | Data relasional, query kompleks | Cache, preferensi, data sederhana |

---

## 4. Hasil Uji Coba

### Fitur yang Diuji
Aplikasi **Catatan Pengeluaran** digunakan untuk menguji CRUD pada kedua storage.

#### ✅ Create (Tambah Data)
- Input keterangan dan nominal
- Tekan tombol **Tambah**
- Data langsung muncul di list bawah

#### ✅ Read (Baca Data)
- Data ditampilkan dalam `ListView` dengan urutan terbaru di atas
- Total pengeluaran dihitung otomatis secara real-time

#### ✅ Update (Edit Data)
- Tekan ikon menu pada item
- Pilih **Update** — dialog muncul dengan data lama
- Edit dan simpan — data langsung diperbarui

#### ✅ Delete (Hapus Data)
- Tekan ikon menu pada item
- Pilih **Hapus** — data langsung terhapus dari list dan storage

### Platform yang Diuji
| Platform | SQFlite | Hive |
|----------|---------|------|
| Windows (Desktop) | ✅ Berhasil | ✅ Berhasil |
| Web (Chrome) | ✅ Berhasil (dengan sqflite_common_ffi_web) | ✅ Berhasil |

---

## 5. Kesimpulan

Keduanya dapat digunakan sebagai local storage di Flutter dengan keunggulan masing-masing:

- **SQFlite** lebih tepat digunakan ketika data memiliki **relasi antar tabel** dan memerlukan **query yang kompleks** (contoh: aplikasi e-commerce, manajemen inventori).
- **Hive** lebih tepat digunakan untuk **data sederhana, preferensi pengguna, atau cache** karena lebih cepat, lebih mudah digunakan, dan mendukung semua platform tanpa konfigurasi tambahan.

Untuk aplikasi catatan pengeluaran sederhana ini, **Hive lebih efisien** karena data tidak memerlukan relasi antar tabel. Namun **SQFlite tetap dipilih** sebagai implementasi utama karena sesuai dengan tujuan pembelajaran package `sqflite` di Flutter.

---

*Dibuat sebagai bagian dari Tugas Praktikum Mobile Programming*
*Universitas Pakuan — Semester 5*

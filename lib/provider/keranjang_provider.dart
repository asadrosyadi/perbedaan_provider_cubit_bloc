import 'package:flutter/foundation.dart';

import '../models/produk.dart';

// PROVIDER: class biasa yang extends ChangeNotifier.
// Widget memanggil method (tambah/kurangi/kosongkan), lalu class ini memanggil
// notifyListeners() supaya widget yang "watch" digambar ulang.
class KeranjangProvider extends ChangeNotifier {
  List<ItemKeranjang> _items = []; // state awal: keranjang kosong

  List<ItemKeranjang> get items => _items;

  void tambah(Produk produk) {
    final daftar = [..._items]; // salin daftar lama (jangan diubah langsung)
    final i = daftar.indexWhere((item) => item.produk.nama == produk.nama);

    if (i == -1) {
      daftar.add(ItemKeranjang(produk: produk)); // produk baru
    } else {
      daftar[i] = ItemKeranjang(produk: produk, jumlah: daftar[i].jumlah + 1);
    }
    _items = daftar;
    notifyListeners(); // beri tahu listener -> Consumer/watch menggambar ulang
  }

  void kurangi(Produk produk) {
    final daftar = [..._items];
    final i = daftar.indexWhere((item) => item.produk.nama == produk.nama);
    if (i == -1) return;

    if (daftar[i].jumlah == 1) {
      daftar.removeAt(i); // jumlah tinggal 1 -> hapus dari keranjang
    } else {
      daftar[i] = ItemKeranjang(produk: produk, jumlah: daftar[i].jumlah - 1);
    }
    _items = daftar;
    notifyListeners();
  }

  void kosongkan() {
    _items = [];
    notifyListeners();
  }
}

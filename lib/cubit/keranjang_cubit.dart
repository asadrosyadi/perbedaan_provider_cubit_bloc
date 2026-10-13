import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/produk.dart';

// CUBIT: state-nya langsung berupa List<ItemKeranjang>.
// Widget memanggil method (tambah/kurangi/kosongkan), lalu Cubit memanggil emit().
class KeranjangCubit extends Cubit<List<ItemKeranjang>> {
  KeranjangCubit() : super([]); // state awal: keranjang kosong

  void tambah(Produk produk) {
    final daftar = [...state]; // salin daftar lama (jangan diubah langsung)
    final i = daftar.indexWhere((item) => item.produk.nama == produk.nama);

    if (i == -1) {
      daftar.add(ItemKeranjang(produk: produk)); // produk baru
    } else {
      daftar[i] = ItemKeranjang(produk: produk, jumlah: daftar[i].jumlah + 1);
    }
    emit(daftar); // kirim state baru -> BlocBuilder menggambar ulang
  }

  void kurangi(Produk produk) {
    final daftar = [...state];
    final i = daftar.indexWhere((item) => item.produk.nama == produk.nama);
    if (i == -1) return;

    if (daftar[i].jumlah == 1) {
      daftar.removeAt(i); // jumlah tinggal 1 -> hapus dari keranjang
    } else {
      daftar[i] = ItemKeranjang(produk: produk, jumlah: daftar[i].jumlah - 1);
    }
    emit(daftar);
  }

  void kosongkan() => emit([]);
}

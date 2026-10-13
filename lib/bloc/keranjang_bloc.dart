import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/produk.dart';

// ===== 1. EVENT: "apa yang terjadi" (dikirim dari tampilan lewat add()) =====
abstract class KeranjangEvent {}

class TambahProduk extends KeranjangEvent {
  TambahProduk(this.produk);
  final Produk produk;
}

class KurangiProduk extends KeranjangEvent {
  KurangiProduk(this.produk);
  final Produk produk;
}

class KosongkanKeranjang extends KeranjangEvent {}

// ===== 2. STATE: "apa yang ditampilkan" di layar =====
class KeranjangState {
  const KeranjangState(this.items);
  final List<ItemKeranjang> items;
}

// ===== 3. BLOC: menerima Event -> menjalankan logika -> emit State baru =====
class KeranjangBloc extends Bloc<KeranjangEvent, KeranjangState> {
  KeranjangBloc() : super(const KeranjangState([])) {
    // Isi tiap handler sama persis dengan method di KeranjangCubit.
    on<TambahProduk>((event, emit) {
      final daftar = [...state.items];
      final i = daftar.indexWhere((item) => item.produk.nama == event.produk.nama);

      if (i == -1) {
        daftar.add(ItemKeranjang(produk: event.produk));
      } else {
        daftar[i] = ItemKeranjang(produk: event.produk, jumlah: daftar[i].jumlah + 1);
      }
      emit(KeranjangState(daftar));
    });

    on<KurangiProduk>((event, emit) {
      final daftar = [...state.items];
      final i = daftar.indexWhere((item) => item.produk.nama == event.produk.nama);
      if (i == -1) return;

      if (daftar[i].jumlah == 1) {
        daftar.removeAt(i);
      } else {
        daftar[i] = ItemKeranjang(produk: event.produk, jumlah: daftar[i].jumlah - 1);
      }
      emit(KeranjangState(daftar));
    });

    on<KosongkanKeranjang>((event, emit) => emit(const KeranjangState([])));
  }
}

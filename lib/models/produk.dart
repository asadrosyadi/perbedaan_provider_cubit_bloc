// Model data: dipakai bersama oleh versi Cubit dan versi BLoC.

class Produk {
  const Produk({required this.nama, required this.harga, required this.ikon});

  final String nama;
  final int harga;
  final String ikon;
}

class ItemKeranjang {
  const ItemKeranjang({required this.produk, this.jumlah = 1});

  final Produk produk;
  final int jumlah;
}

// Daftar menu kantin (data contoh).
const daftarProduk = [
  Produk(nama: 'Nasi Goreng', harga: 15000, ikon: '🍛'),
  Produk(nama: 'Mie Ayam', harga: 13000, ikon: '🍜'),
  Produk(nama: 'Es Teh', harga: 5000, ikon: '🥤'),
];

// Fungsi bantu supaya format harga sama di semua halaman.
String rupiah(int nilai) => 'Rp$nilai';

int hitungTotalHarga(List<ItemKeranjang> items) =>
    items.fold(0, (total, item) => total + item.produk.harga * item.jumlah);

int hitungTotalItem(List<ItemKeranjang> items) =>
    items.fold(0, (total, item) => total + item.jumlah);

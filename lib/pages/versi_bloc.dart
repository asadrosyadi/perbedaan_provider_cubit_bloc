import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/keranjang_bloc.dart';
import '../models/produk.dart';

// Kerangka aplikasi versi BLOC: sama persis dengan versi Cubit,
// bedanya hanya sumber data (KeranjangBloc) dan cara mengirim aksi (add Event).
class KantinBloc extends StatefulWidget {
  const KantinBloc({super.key});

  @override
  State<KantinBloc> createState() => _KantinBlocState();
}

class _KantinBlocState extends State<KantinBloc> {
  int _indeks = 0;

  @override
  Widget build(BuildContext context) {
    final totalItem = context.select<KeranjangBloc, int>(
      (bloc) => hitungTotalItem(bloc.state.items),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_indeks == 0 ? 'Menu Kantin (BLoC)' : 'Keranjang ($totalItem)'),
      ),
      body: IndexedStack(
        index: _indeks,
        children: const [HalamanProdukBloc(), HalamanKeranjangBloc()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (i) {
          // Tutup SnackBar agar tidak menutupi tombol di halaman lain.
          ScaffoldMessenger.of(context).clearSnackBars();
          setState(() => _indeks = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
        ],
      ),
    );
  }
}

// ---------------- Halaman Produk (+ SnackBar lewat BlocListener) ----------------
class HalamanProdukBloc extends StatelessWidget {
  const HalamanProdukBloc({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocListener: untuk EFEK SAMPING (SnackBar), tidak menggambar apa pun.
    return BlocListener<KeranjangBloc, KeranjangState>(
      // Hanya bereaksi saat jumlah item BERTAMBAH (bukan saat dikurangi/dikosongkan).
      listenWhen: (lama, baru) =>
          hitungTotalItem(baru.items) > hitungTotalItem(lama.items),
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars() // buang SnackBar lama agar tidak menumpuk
          ..showSnackBar(
            const SnackBar(content: Text('Produk ditambahkan ke keranjang')),
          );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final produk in daftarProduk)
            Card(
              child: ListTile(
                leading: Text(produk.ikon, style: const TextStyle(fontSize: 32)),
                title: Text(produk.nama),
                subtitle: Text(rupiah(produk.harga)),
                trailing: FilledButton(
                  // BLOC: kirim Event lewat add()
                  onPressed: () =>
                      context.read<KeranjangBloc>().add(TambahProduk(produk)),
                  child: const Text('Tambah'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------- Halaman Keranjang ----------------
class HalamanKeranjangBloc extends StatelessWidget {
  const HalamanKeranjangBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeranjangBloc, KeranjangState>(
      builder: (context, state) {
        final items = state.items;
        if (items.isEmpty) {
          return const Center(child: Text('Keranjang masih kosong'));
        }

        final bloc = context.read<KeranjangBloc>();
        return Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  for (final item in items)
                    ListTile(
                      title: Text(item.produk.nama),
                      subtitle: Text('${item.jumlah} x ${rupiah(item.produk.harga)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => bloc.add(KurangiProduk(item.produk)),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${item.jumlah}'),
                          IconButton(
                            onPressed: () => bloc.add(TambahProduk(item.produk)),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total: ${rupiah(hitungTotalHarga(items))}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => bloc.add(KosongkanKeranjang()),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Kosongkan Keranjang'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

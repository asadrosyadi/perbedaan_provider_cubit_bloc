import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/keranjang_cubit.dart';
import '../models/produk.dart';

// Kerangka aplikasi versi CUBIT: NavigationBar Produk <-> Keranjang.
class KantinCubit extends StatefulWidget {
  const KantinCubit({super.key});

  @override
  State<KantinCubit> createState() => _KantinCubitState();
}

class _KantinCubitState extends State<KantinCubit> {
  int _indeks = 0; // state lokal -> cukup pakai setState()

  @override
  Widget build(BuildContext context) {
    // context.select: hanya rebuild kalau totalItem berubah.
    final totalItem = context.select<KeranjangCubit, int>(
      (cubit) => hitungTotalItem(cubit.state),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_indeks == 0 ? 'Menu Kantin (Cubit)' : 'Keranjang ($totalItem)'),
      ),
      body: IndexedStack(
        index: _indeks,
        children: const [HalamanProdukCubit(), HalamanKeranjangCubit()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (i) => setState(() => _indeks = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
        ],
      ),
    );
  }
}

// ---------------- Halaman Produk ----------------
class HalamanProdukCubit extends StatelessWidget {
  const HalamanProdukCubit({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final produk in daftarProduk)
          Card(
            child: ListTile(
              leading: Text(produk.ikon, style: const TextStyle(fontSize: 32)),
              title: Text(produk.nama),
              subtitle: Text(rupiah(produk.harga)),
              trailing: FilledButton(
                // CUBIT: panggil method secara langsung
                onPressed: () => context.read<KeranjangCubit>().tambah(produk),
                child: const Text('Tambah'),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------- Halaman Keranjang ----------------
class HalamanKeranjangCubit extends StatelessWidget {
  const HalamanKeranjangCubit({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder: menggambar ulang setiap kali Cubit emit state baru.
    return BlocBuilder<KeranjangCubit, List<ItemKeranjang>>(
      builder: (context, items) {
        if (items.isEmpty) {
          return const Center(child: Text('Keranjang masih kosong'));
        }

        final cubit = context.read<KeranjangCubit>();
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
                            onPressed: () => cubit.kurangi(item.produk),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${item.jumlah}'),
                          IconButton(
                            onPressed: () => cubit.tambah(item.produk),
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
                    onPressed: cubit.kosongkan,
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

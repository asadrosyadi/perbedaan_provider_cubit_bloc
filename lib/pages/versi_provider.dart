import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/produk.dart';
import '../provider/keranjang_provider.dart';

// Kerangka aplikasi versi PROVIDER: NavigationBar Produk <-> Keranjang.
class KantinProvider extends StatefulWidget {
  const KantinProvider({super.key});

  @override
  State<KantinProvider> createState() => _KantinProviderState();
}

class _KantinProviderState extends State<KantinProvider> {
  int _indeks = 0; // state lokal -> cukup pakai setState()

  @override
  Widget build(BuildContext context) {
    // context.select: hanya rebuild kalau totalItem berubah.
    final totalItem = context.select<KeranjangProvider, int>(
      (keranjang) => hitungTotalItem(keranjang.items),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_indeks == 0 ? 'Menu Kantin (Provider)' : 'Keranjang ($totalItem)'),
      ),
      body: IndexedStack(
        index: _indeks,
        children: const [HalamanProdukProvider(), HalamanKeranjangProvider()],
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
class HalamanProdukProvider extends StatelessWidget {
  const HalamanProdukProvider({super.key});

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
                // PROVIDER: context.read -> ambil objek tanpa ikut rebuild
                onPressed: () => context.read<KeranjangProvider>().tambah(produk),
                child: const Text('Tambah'),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------- Halaman Keranjang ----------------
class HalamanKeranjangProvider extends StatelessWidget {
  const HalamanKeranjangProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer: menggambar ulang setiap kali notifyListeners() dipanggil.
    return Consumer<KeranjangProvider>(
      builder: (context, keranjang, child) {
        final items = keranjang.items;
        if (items.isEmpty) {
          return const Center(child: Text('Keranjang masih kosong'));
        }

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
                            onPressed: () => keranjang.kurangi(item.produk),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${item.jumlah}'),
                          IconButton(
                            onPressed: () => keranjang.tambah(item.produk),
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
                    onPressed: keranjang.kosongkan,
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

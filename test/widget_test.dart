import 'package:flutter_test/flutter_test.dart';

import 'package:progamsederhana/bloc/keranjang_bloc.dart';
import 'package:progamsederhana/cubit/keranjang_cubit.dart';
import 'package:progamsederhana/main.dart';
import 'package:progamsederhana/models/produk.dart';

void main() {
  const nasiGoreng = Produk(nama: 'Nasi Goreng', harga: 15000, ikon: '🍛');

  test('KeranjangCubit: tambah, kurangi, kosongkan', () {
    final cubit = KeranjangCubit();
    cubit.tambah(nasiGoreng);
    cubit.tambah(nasiGoreng);
    expect(cubit.state.single.jumlah, 2);

    cubit.kurangi(nasiGoreng);
    expect(cubit.state.single.jumlah, 1);

    cubit.kosongkan();
    expect(cubit.state, isEmpty);
  });

  test('KeranjangBloc: Event menghasilkan State yang benar', () async {
    final bloc = KeranjangBloc();
    bloc.add(TambahProduk(nasiGoreng));
    bloc.add(TambahProduk(nasiGoreng));
    bloc.add(KurangiProduk(nasiGoreng));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.items.single.jumlah, 1);

    bloc.add(KosongkanKeranjang());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.items, isEmpty);
    await bloc.close();
  });

  for (final versi in ['Versi Cubit', 'Versi BLoC']) {
    testWidgets('$versi: tambah produk lalu cek keranjang', (tester) async {
      await tester.pumpWidget(const AplikasiKantin());
      await tester.tap(find.text(versi));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tambah').first); // Nasi Goreng
      await tester.tap(find.text('Tambah').last); // Es Teh
      await tester.pump();

      await tester.tap(find.text('Keranjang'));
      await tester.pumpAndSettle();
      expect(find.text('Keranjang (2)'), findsOneWidget);
      expect(find.text('Total: Rp20000'), findsOneWidget);

      await tester.tap(find.text('Kosongkan Keranjang'));
      await tester.pumpAndSettle();
      expect(find.text('Keranjang masih kosong'), findsOneWidget);
    });
  }
}

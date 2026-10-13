// Skrip untuk mengambil screenshot aplikasi secara otomatis.
// Jalankan: flutter test test_screenshot --update-goldens
// Hasil gambar tersimpan di folder screenshots/.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progamsederhana/main.dart';

const _fontFlutter = r'C:\flutter\bin\cache\artifacts\material_fonts';

Future<void> _muatFont(String keluarga, List<String> berkas) async {
  final loader = FontLoader(keluarga);
  for (final b in berkas) {
    final bytes = File(b).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    await _muatFont('Roboto', [
      '$_fontFlutter\\roboto-regular.ttf',
      '$_fontFlutter\\roboto-medium.ttf',
      '$_fontFlutter\\roboto-bold.ttf',
    ]);
    await _muatFont('MaterialIcons', ['$_fontFlutter\\materialicons-regular.otf']);
    await _muatFont('Emoji', [r'C:\Windows\Fonts\seguiemj.ttf']);
  });

  testWidgets('ambil screenshot', (tester) async {
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Tema sama dengan AplikasiKantin, hanya ditambah font agar teks terbaca.
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Roboto',
        fontFamilyFallback: const ['Emoji'],
      ),
      home: const HalamanPilihVersi(),
    ));

    Future<void> foto(String nama) async {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../screenshots/$nama.png'),
      );
    }

    Future<void> tekan(Finder f) async {
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    // ---------- Halaman awal ----------
    await foto('01_pilih_versi');

    // ---------- Versi Cubit ----------
    await tekan(find.text('Versi Cubit'));
    await foto('02_cubit_produk');

    final tambah = find.text('Tambah');
    await tekan(tambah.at(0)); // Nasi Goreng
    await tekan(tambah.at(0)); // Nasi Goreng lagi
    await tekan(tambah.at(1)); // Mie Ayam
    await tekan(tambah.at(2)); // Es Teh
    await tekan(find.text('Keranjang'));
    await foto('03_cubit_keranjang');

    await tekan(find.byIcon(Icons.remove_circle_outline).first); // kurangi Nasi Goreng
    await foto('04_cubit_keranjang_dikurangi');

    await tekan(find.text('Kosongkan Keranjang'));
    await foto('05_cubit_keranjang_kosong');

    // Kembali ke menu awal.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ---------- Versi BLoC ----------
    await tekan(find.text('Versi BLoC'));
    await tester.tap(find.text('Tambah').at(1)); // Mie Ayam
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600)); // animasi SnackBar
    await foto('06_bloc_produk_snackbar');

    await tester.tap(find.text('Tambah').at(1)); // Mie Ayam lagi
    await tester.tap(find.text('Tambah').at(2)); // Es Teh
    await tester.pump();
    await tekan(find.text('Keranjang'));
    await foto('07_bloc_keranjang');

    debugDisableShadows = true;
  });
}
